
-- Testbench
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity testbench is
-- empty
end testbench;

architecture tb of testbench is
	-- Component Declaration for the Unit Under Test (UUT)
     -- We're slowing down the clock to speed up simulation time
    constant FrequencyHz : integer := 10; -- 10 Hz
    constant clk_period  : time    := 1000 ms / FrequencyHz;

  -- DUT component
  component geladeira
    port (
      -- Botões
      gelar_toddynho : in bit;
      
      -- Sensores
      sensor_porta_aberta : in bit;
      sensor_peso : in integer range 0 to 1023;
      temperatura_geladeira : in integer;
      temperatura_freezer : buffer integer;
      
      -- Alertas
      alerta_porta_aberta : out bit;
      recomendacao_fechar_freezer : out bit;
      alerta_geladeira_vazia : out bit;
      alerta_erro_de_temperatura : out bit;
      
      -- Controladores
      modo_economico : out bit;
      clock: in bit
    );
  end component;

  signal gelar_toddynho_tb : bit := '0';
  signal sensor_porta_aberta_tb : bit := '0';
  signal sensor_peso_tb : integer := 500; -- Defina um valor adequado para o teste
  signal temperatura_geladeira_tb : integer := 10; -- Defina uma temperatura válida
  signal temperatura_freezer_tb : integer := 0; -- Defina a temperatura do freezer
  signal alerta_porta_aberta_tb : bit;
  signal recomendacao_fechar_freezer_tb : bit;
  signal alerta_geladeira_vazia_tb : bit;
  signal alerta_erro_de_temperatura_tb : bit;
  signal modo_economico_tb : bit;

  signal clk : bit := '0';
  signal reset : std_logic := '1';

  begin

    -- Clock process
    Clk_process: process
    begin
        while now < 180 sec loop  -- Simulate for 10 seconds (adjust as needed)
            if reset = '1' then
                clk <= '0';
                wait for clk_period/2;
                clk <= '1';
                wait for clk_period/2;
            else
                exit;  -- Exit the loop if reset is de-asserted
            end if;
        end loop;
        wait;
    end process;

    -- Connect DUT
    DUT: geladeira
      port map (
        gelar_toddynho => gelar_toddynho_tb,
        sensor_porta_aberta => sensor_porta_aberta_tb,
        sensor_peso => sensor_peso_tb,
        temperatura_geladeira => temperatura_geladeira_tb,
        temperatura_freezer => temperatura_freezer_tb,
        alerta_porta_aberta => alerta_porta_aberta_tb,
        recomendacao_fechar_freezer => recomendacao_fechar_freezer_tb,
        alerta_geladeira_vazia => alerta_geladeira_vazia_tb,
        alerta_erro_de_temperatura => alerta_erro_de_temperatura_tb,
        modo_economico => modo_economico_tb,
        clock => clk
      );

    stimulus_process: process
    begin
    	-- hold reset state for 100 ns.
        wait until rising_edge(clk);
    
        -- PORTA ABERTA
        sensor_porta_aberta_tb <= '1';
        wait for 35 sec;
        assert(alerta_porta_aberta_tb = '1') report "porta erro" severity note;
        -- PORTA FECHADA
        sensor_porta_aberta_tb <= '0';
        wait for 65 sec;
        assert (modo_economico_tb = '1') report "modo economico" severity note;
        
        -- TEMPERATURA GELADEIRA
        temperatura_geladeira_tb <= 12;
        wait for 1 sec;
        assert(alerta_erro_de_temperatura_tb = '1') report "temperatura erro" severity note;
        
        -- MODO TODDYNHO
        gelar_toddynho_tb <= '1';
        wait for 1 sec;
        assert (temperatura_freezer_tb = 0) report "toddynho erro" severity note;
        
        -- ALERTA MERCADO
        sensor_peso_tb <= 200;
        wait for 1 sec;
        assert (alerta_geladeira_vazia_tb = '1') report "hora das compras erro" severity note;
        sensor_peso_tb <= 1001;
        wait for 1 sec;
        assert (alerta_geladeira_vazia_tb = '0') report "hora das compras erro" severity note;
        
        reset <= '0';

      assert false report "Test done." severity note;
      wait;
    end process;

  end tb;
