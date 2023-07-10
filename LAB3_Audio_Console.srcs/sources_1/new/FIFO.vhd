library IEEE;
	use IEEE.STD_LOGIC_1164.all;
	use IEEE.NUMERIC_STD.ALL;

entity FIFO is
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
end FIFO;

architecture Behavioral of FIFO is

	------------------------ TYPES DECLARATION ----------------------

	------ Memory element ------
	type FIFO_DATA_TYPE is array (0 to FIFO_DEPTH-1) of std_logic_vector(din'range);
	----------------------------


	---------------------------- SIGNALS ----------------------------

	---------- Memory element -----------
	signal fifo_data    : FIFO_DATA_TYPE := (others => (others => '0')) ;
	--------------------------------------

	------ Write and read "pointers" ------
	signal write_index  : integer range 0 to FIFO_DEPTH-1 := 0;
	signal read_index   : integer range 0 to FIFO_DEPTH-1 := 0;
	---------------------------------------

    --Internal signal of write enable
    signal wr_en_int    : std_logic;

begin

	----------------------------- DATA FLOW ---------------------------
	dout <= fifo_data(read_index);
    wr_en_int <= wr_en;
	-------------------------------------------------------------------


	----------------------------- PROCESS ------------------------------

	------ Sync Process --------
	process (aclk) is
        variable is_writing	: std_logic;
	begin
		if rising_edge(aclk) then
			if arstn = '0' then
				write_index	<= 0;
				read_index	<= 1;

			else
                if wr_en_int = '1' then 

                    if write_index = FIFO_DEPTH -1 then 
                        write_index <= 0;
                    else 
                        fifo_data(write_index) <= din;
                        write_index <= write_index + 1;
                    end if;

                    if read_index = FIFO_DEPTH-1 then
						read_index <= 0;
					else
						read_index <= read_index + 1;
					end if;

                    wr_en_int <= '0';
                    

                end if;
			end if;
		end if;
	end process FIFO_engine;
	----------------------------

	-------------------------------------------------------------------



end Behavioral;
