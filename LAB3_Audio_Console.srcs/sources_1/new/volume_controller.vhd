library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity volume_controller is
    Port(
    -- AXI slave port
        s_axis_tdata    :   in      STD_LOGIC_VECTOR (23 downto 0);
        s_axis_tvalid   :   in      STD_LOGIC;
        s_axis_tlast    :   in      STD_LOGIC;
        s_axis_tready   :   out     STD_LOGIC;

    -- Clock and reset
        aclk            :   in      STD_LOGIC;
        aresetn         :   in      STD_LOGIC;

    -- Inputs from the joystick
        volume          :   in      STD_LOGIC_VECTOR (9 downto 0);

    -- AXI master port
        m_axis_tdata    :   out     STD_LOGIC_VECTOR (23 downto 0);
        m_axis_tvalid   :   out     STD_LOGIC;
        m_axis_tlast    :   out     STD_LOGIC;
        m_axis_tready   :   in      STD_LOGIC
        );
end volume_controller;

architecture Behavioral of volume_controller is

-- In order to pipeline we use an output and an input registe so that we can
-- write and read at the same time.
signal  out_reg             :   STD_LOGIC_VECTOR(23 downto 0);
signal  m_axis_tlast_sig    :   STD_LOGIC;
signal  in_reg              :   STD_LOGIC_VECTOR(23 downto 0);

-- Volume control is logarithmic: we manage it with shift_val of 1 bit every 64 volume variation
signal  shift_val               :   INTEGER range 0 to 8;

 -- The direction of the shift_val is controlled by the MSB of "volume" input variable:
 -- if dir = '0' volume decreases, if dir = '1' volume increases.
signal  dir                 :   STD_LOGIC;                     

---------------------FSM DEFINITION--------------------
type state is (IDLE, COMPUTE, TRANSFER);
signal vol_state : state := IDLE;

begin

------------------------DATAFLOW------------------------
dir <= volume(9);
with dir select
        shift_val <= to_integer(unsigned(volume(8 downto 6)))   when '1',
                 8-to_integer(unsigned(volume(8 downto 6))) when '0';


------------------------PROCESS------------------------

FSM : process(aclk, aresetn)
    begin
        if rising_edge(aclk) then
            if aresetn = '0' then
    
            else
                case vol_state is
                    when IDLE =>

                    when COMPUTE =>
                        if dir = '1' then                   -- Volume UP

                            if in_reg(23) = in_reg(22) then
                                out_reg <= (23 => in_reg(23), 22 downto shift_val => in_reg(23-shift_val downto 0), Others => '0');
                            else    -- Saturation!
                                out_reg <= (23 => in_reg(23), Others => NOT in_reg(23));
                            end if;

                        else                                -- Volume DOWN
                            

                        end if;

                    when TRANSFER =>

                end case;

            end if;

        end if;

end process;

end Behavioral;
