-------------------------------------------------------
--! @file multiplicador_tb.vhd
--! @brief testbench for synchronous multiplier
--! @author Edson Midorikawa (emidorik@usp.br)
--! @date 2020-06-15
-------------------------------------------------------

library ieee;
use ieee.numeric_bit.all;

entity multiplicador_tb_vetorteste is
end entity;

architecture tb of multiplicador_tb_vetorteste is
  
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
    
  
  type pattern_type is record
  --Entradas
  op1: bit_vector(3 downto 0);
  op2 : bit_vector(3 downto 0);
  --Saídas
  multiplicacao_esperada : bit_vector(7 downto 0);
  end record;
  
  type pattern_array is array (natural range <>) of pattern_type;
  
  constant patterns: pattern_array :=
  -- op1     op2     multiplicacao_esperada
  (("0011", "0110", "00010010"),
  ("1111", "1011", "10100101"),
  ("1111", "0000", "00000000"),
  ("0001", "1011", "00001011"));
  
  begin
    
    assert false report "simulation start" severity note;
    keep_simulating <= '1';
    -- Reset inicial (1 periodo de clock) - não precisa repetir
    rst_in <= '1'; start_in <= '0';      
    
    --para cada padrão de teste no vetor
    for i in patterns'range loop
      ---- Caso de teste 1: A=3, B=6
        Va_in <= patterns(i).op1;
        Vb_in <= patterns(i).op2;
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
        assert (result_out/= patterns(i).multiplicacao_esperada) report "OK:" severity note;

      end loop;
    
    assert false report "simulation end" severity note;
    keep_simulating <= '0';
    
    wait; -- fim da simulação: aguarda indefinidamente
  end process;


end architecture;
