-------------------------------------------------------
--! @file multiplicador_tb.vhd
--! @brief testbench for synchronous multiplier
--! @author Edson Midorikawa (emidorik@usp.br)
--! @date 2020-06-15
-------------------------------------------------------

library ieee;
use ieee.numeric_bit.all;
use std.textio.all;

entity multiplicador_tb_arquivo is
end entity;

architecture tb of multiplicador_tb_arquivo is
  
  -- Componente a ser testado (Device Under Test -- DUT)
  component multiplicador
    port (
      Clock:    in  bit;
      Reset:    in  bit;
      Start:    in  bit;
      Va,Vb:    in  bit_vector(3 downto 0);
      Vresult:  out bit_vector(7 downto 0);
      Ready:    out bit
    );
  end component;
  
  -- Declaração de sinais para conectar a componente
  signal clk_in: bit := '0';
  signal rst_in, start_in, ready_out: bit := '0';
  signal va_in, vb_in: bit_vector(3 downto 0);
  signal result_out: bit_vector(7 downto 0);

  -- Configurações do clock
  signal keep_simulating: bit := '0'; -- delimita o tempo de geração do clock
  constant clockPeriod : time := 1 ns;
  
begin
  -- Gerador de clock: executa enquanto 'keep_simulating = 1', com o período
  -- especificado. Quando keep_simulating=0, clock é interrompido, bem como a 
  -- simulação de eventos
  clk_in <= (not clk_in) and keep_simulating after clockPeriod/2;
  
  ---- O código abaixo, sem o "keep_simulating", faria com que o clock executasse
  ---- indefinidamente, de modo que a simulação teria que ser interrompida manualmente
  -- clk_in <= (not clk_in) after clockPeriod/2; 
  
  -- Conecta DUT (Device Under Test)
  dut: multiplicador
       port map(Clock=>   clk_in,
                Reset=>   rst_in,
                Start=>   start_in,
                Va=>      va_in,
                Vb=>      vb_in,
                Vresult=> result_out,
                Ready=>   ready_out
      );

  ---- Gera sinais de estimulo
  stimulus: process is
    
  file tb_file : text open read_mode is "multiplicacao_tb_arquivo.dat";
  variable tb_line: line;
  variable space: character;
  variable op1, op2: bit_vector(3 downto 0);
  variable multiplicacao_esperada: bit_vector(7 downto 0);
  
  
  begin
    assert false report "simulation start" severity note;
    keep_simulating <= '1';
    -- Reset inicial (1 periodo de clock) - não precisa repetir
    rst_in <= '1'; start_in <= '0';

        
  	while not endfile(tb_file) loop  -- Enquanto não chegar no final do arquivo ...
         readline(tb_file, tb_line);  -- Lê a próxima linha
         read(tb_line, op1);   -- Da linha que foi lida, lê o primeiro parâmetro (op1)
         read(tb_line, space); -- Lê o espaço após o primeiro parâmetro (separador)
         read(tb_line, op2);   -- Da linha que foi lida, lê o segundo parâmetro (op2)
         read(tb_line, space); -- Lê o próximo espaço usado como separador
         read(tb_line, multiplicacao_esperada);  -- Da linha que foi lida, lê o terceiro parâmetro (soma_esperada)
         Va_in <= op1;
         Vb_in <= op2;
         wait for clockPeriod;
         rst_in <= '0';
         wait until falling_edge(clk_in);
         -- pulso do sinal de Start
         start_in <= '1';
         wait until falling_edge(clk_in);
         start_in <= '0';
         -- espera pelo termino da multiplicacao
         wait until ready_out='1';
         -- verifica resultado
         assert (result_out/= multiplicacao_esperada) report "OK:" severity note;
    end loop;
    
    assert false report "simulation end" severity note;
    keep_simulating <= '0';
    
    wait; -- fim da simulação: aguarda indefinidamente
  end process;


end architecture;
