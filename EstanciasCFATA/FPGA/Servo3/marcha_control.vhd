library IEEE;
use IEEE.std_logic_1164.ALL;
use IEEE.numeric_std.ALL;

entity marcha_control is
    Port (
        clk : in std_logic;
        reset : in std_logic;
        start : in std_logic; -- Botón para iniciar
        servo1_pos : out std_logic_vector(7 downto 0);
        servo2_pos : out std_logic_vector(7 downto 0);
        servo3_pos : out std_logic_vector(7 downto 0);
        servo4_pos : out std_logic_vector(7 downto 0)
    );
end marcha_control;

architecture fsm of marcha_control is
    type state_type is (idle, estado1, estado2, estado3, estado4);
    signal state, next_state : state_type;

    signal position1, position2, position3, position4 : std_logic_vector(7 downto 0);
begin
    process (clk, reset)
    begin
        if reset = '1' then
            state <= idle;
        elsif rising_edge(clk) then
            state <= next_state;
        end if;
    end process;

    process (state, start)
    begin
        case state is
            when idle =>
                if start = '1' then
                    next_state <= estado1;
                else
                    next_state <= idle;
                end if;
            when estado1 =>
                position1 <= "00101100"; -- Posición para servo 1
                position2 <= "00101100"; -- Posición para servo 2
                position3 <= "00010010"; -- Posición para servo 3
                position4 <= "00010010"; -- Posición para servo 4
                next_state <= estado2;
            when estado2 =>
                position1 <= "00010010"; -- Posición para servo 1
                position2 <= "00010010"; -- Posición para servo 2
                position3 <= "00101100"; -- Posición para servo 3
                position4 <= "00101100"; -- Posición para servo 4
                next_state <= estado3;
            when estado3 =>
                position1 <= "00100000"; -- Posición para servo 1
                position2 <= "00100000"; -- Posición para servo 2
                position3 <= "00100000"; -- Posición para servo 3
                position4 <= "00100000"; -- Posición para servo 4
                next_state <= estado4;
            when estado4 =>
                position1 <= "00000000"; -- Posición para servo 1
                position2 <= "00000000"; -- Posición para servo 2
                position3 <= "00000000"; -- Posición para servo 3
                position4 <= "00000000"; -- Posición para servo 4
                next_state <= estado1;
            when others =>
                next_state <= idle;
        end case;
    end process;

    servo1_pos <= position1;
    servo2_pos <= position2;
    servo3_pos <= position3;
    servo4_pos <= position4;
end fsm;
