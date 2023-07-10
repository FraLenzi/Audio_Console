library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity dual_moving_average is
    Generic(
        N_SAMPLES       : integer := 32
    );
    Port (    
        --SLAVE INPUT PORT
        s_axis_tdata    :   in STD_LOGIC_VECTOR (23 downto 0);
        s_axis_tvalid   :   in STD_LOGIC;
        s_axis_tready   :   out STD_LOGIC;
        s_axis_tlast    :   in STD_LOGIC;

        --MASTER OUTPUT PORT
        m_axis_tdata    :   out STD_LOGIC_VECTOR (23 downto 0);
        m_axis_tvalid   :   out STD_LOGIC;
        m_axis_tready   :   in STD_LOGIC;
        m_axis_tlast    :   out STD_LOGIC;
        
        aclk            :   in STD_LOGIC;
        aresetn         :   in STD_LOGIC;
        
        --Enabling signal for Moving Average
        filter_enable   :   in STD_LOGIC
        );
        end dual_moving_average; 
        
architecture Behavioral of dual_moving_average is
            
    component FIFO is
        generic (
            FIFO_WIDTH : natural := 24;
            FIFO_DEPTH : integer := 32
        );
        port (
    
            -------- Reset/Clock -------
            arstn		: in std_logic;
            aclk		: in std_logic;
            ----------------------------
            ---------- DATA ------------
            wr_en	: in	std_logic;
            din		: in	std_logic_vector(FIFO_WIDTH-1 downto 0);
            dout	: out 	std_logic_vector(FIFO_WIDTH-1 downto 0)
            ----------------------------
        );
    end component;

    --Signals for DX_CHANNEL FIFO
    signal wr_en_dx   : std_logic;
    signal din_dx     : std_logic_vector(s_axis_tdata'RANGE);
    signal dout_dx    : std_logic_vector(s_axis_tdata'RANGE);
    
    --Signals for DX_CHANNEL FIFO
    signal wr_en_sx   : std_logic;
    signal din_sx     : std_logic_vector(s_axis_tdata'RANGE);
    signal dout_sx    : std_logic_vector(s_axis_tdata'RANGE);
    
    --Average registers
    signal average_reg_sx  : STD_LOGIC_VECTOR(23 downto 0) := (Others => '0');
    signal average_reg_dx  : STD_LOGIC_VECTOR(23 downto 0) := (Others => '0');

    --State definition for FSM for Reception and Trasmission
    type state  is (IDLE, RECEPTION, TRASMISSION);
    signal cur_state     : state;


    type channel_type is (RX,SX);
    signal channel  : channel_type := SX;


begin

    FIFO_sx : FIFO 
        Generic map(
            FIFO_WIDTH => s_axis_tdata'LENGTH,
            FIFO_DEPTH => N_SAMPLES
        )
        Port map(
            -------- Reset/Clock -------
            arstn		=> aresetn,
            aclk		=> aclk,
            ---------- DATA ------------
            wr_en	    => wr_en_sx,
            din		    => din_sx,
            dout	    => dout_sx
        );

    FIFO_dx : FIFO 
        Generic map(
            FIFO_WIDTH => s_axis_tdata'LENGTH,
            FIFO_DEPTH => N_SAMPLES
        )
        Port map(
            -------- Reset/Clock -------
            arstn		=> aresetn,
            aclk		=> aclk,
            ---------- DATA ------------
            wr_en	    => wr_en_dx,
            din		    => din_dx,
            dout	    => dout_dx
        );
    
    -------------------PROCESS--------------------------------
    process(aclk, aresetn)
    begin

        if aresetn = '1' then 
            
        s_axis_tready   <= '0';
    
        elsif rising_edge(aclk) then

            case cur_state is

                when IDLE =>

                    m_axis_tvalid <= '0';
                    cur_state   <= RECEPTION;

                when RECEPTION =>

                        if filter_enable = '1' then 

                            if s_axis_tvalid = '1' and s_axis_tlast = '0' then --LEFT CHANNEL
                                s_axis_tready   <= '1';

                                wr_en_sx        <= '1';                
                                din_sx          <= s_axis_tdata;

                                average_reg_sx  <= average_reg_sx + (s_axis_tdata - dout_sx)/N_SAMPLES; --DA OTTIMIZZARE(PIPELINE)

                            end if;

                            if s_axis_tvalid = '1' and s_axis_tlast = '1' then --RIGHT CHANNEL
                                s_axis_tready   <= '1';
                    
                                wr_en_sx        <= '1';
                                din_dx          <= s_axis_tdata;
                                                    
                                average_reg_dx  <= average_reg_dx + (s_axis_tdata - dout_dx)/N_SAMPLES; --DA OTTIMIZZARE(PIPELINE)

                                cur_state <= TRASMISSION;
                            end if;

                        else 

                            wr_en_dx    <= '0';
                            wr_en_sx    <= '0';
                            
                        end if;

                when TRASMISSION =>

                    if channel = SX and m_axis_tready = '1' then
                        m_axis_tdata    <= average_reg_sx;
                        m_axis_tvalid   <= '1';
                        m_axis_tlast    <= '0';
                        channel         <= RX;
                    end if;

                    if channel = RX and m_axis_tready = '1' then
                        m_axis_tdata    <= average_reg_dx;
                        m_axis_tvalid   <= '1';
                        m_axis_tlast    <= '1';
                        channel         <= SX;
                        cur_state       <= IDLE;
                    end if;
            end case;

        end if;
    end process;

end Behavioral;