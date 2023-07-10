library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity mute is  
    Port(

        --SLAVE INPUT PORT
        s_axis_tdata    : in    STD_LOGIC_VECTOR (23 downto 0);
        s_axis_tvalid   : in    STD_LOGIC;
        s_axis_tready   : out   STD_LOGIC;
        s_axis_tlast    : in    STD_LOGIC;   

        --Input port for enabling port
        mute_enable     : in    STD_LOGIC;

        --MASTER OUTPUT PORT
        m_axis_tdata    : out   STD_LOGIC_VECTOR (23 downto 0);
        m_axis_tvalid   : out   STD_LOGIC;
        m_axis_tready   : in    STD_LOGIC;
        m_axis_tlast    : out   STD_LOGIC
        );
end mute;

architecture Behavioral of mute is

begin

    s_axis_tready   <= '1';

    m_axis_tvalid   <= s_axis_tvalid;
    m_axis_tlast    <= s_axis_tlast;

    process(mute_enable)
    begin

        if m_axis_tready = '1' then 

            if mute_enable = '0' then
                m_axis_tdata    <= s_axis_tdata;
            else
                m_axis_tdata    <= (others => '0'); 
            end if;

        end if;
    end process;

end Behavioral;
