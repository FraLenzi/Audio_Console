library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity led_controller is
    Generic(
        --HEX Color code for NORMAL,FILTER and MUTE modes
        LED_COLOR_NORMAL    : STD_LOGIC_VECTOR(20 downto 0) := x"00_FF_00"; --GREEN by default
        LED_COLOR_FILTER    : STD_LOGIC_VECTOR(20 downto 0) := x"00_00_FF"; --BLUE by default
        LED_COLOR_MUTE      : STD_LOGIC_VECTOR(20 downto 0) := x"FF_00_00"  --RED by default
    );
    Port( 
        mute_enable     :   in      STD_LOGIC;
        filter_enable   :   in      STD_LOGIC;
        
        led_b           :   out     STD_LOGIC_VECTOR(7 downto 0);
        led_g           :   out     STD_LOGIC_VECTOR(7 downto 0);
        led_r           :   out     STD_LOGIC_VECTOR(7 downto 0)
        );
end led_controller;

architecture Behavioral of led_controller is

begin

    process(mute_enable, filter_enable)
    begin

        if mute_enable = '1' then

           --We set the MUTE COLOR
           led_b   <= LED_COLOR_MUTE(7 downto 0);
           led_g   <= LED_COLOR_MUTE(15 downto 8);
           led_r   <= LED_COLOR_MUTE(20 downto 16);
        
        else
            
            if filter_enable = '1' then 
                --We set the FILTER COLOR
                led_b   <= LED_COLOR_FILTER(7 downto 0);
                led_g   <= LED_COLOR_FILTER(15 downto 8);
                led_r   <= LED_COLOR_FILTER(20 downto 16);
            else
                --We set the NORMAL COLOR
                led_b   <= LED_COLOR_NORMAL(7 downto 0);
                led_g   <= LED_COLOR_NORMAL(15 downto 8);
                led_r   <= LED_COLOR_NORMAL(20 downto 16);
            end if;
        end if;
    end process;

end Behavioral;
