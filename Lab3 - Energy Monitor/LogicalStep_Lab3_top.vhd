library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity LogicalStep_Lab3_top is port (
   clkin_50		: in	std_logic;
	pb				: in	std_logic_vector(3 downto 0);
 	sw   			: in  std_logic_vector(7 downto 0); -- The switch inputs
   leds			: out std_logic_vector(7 downto 0);	-- for displaying the switch content
   seg7_data 	: out std_logic_vector(6 downto 0); -- 7-bit outputs to a 7-segment
	seg7_char1  : out	std_logic;							-- seg7 digi selectors
	seg7_char2  : out	std_logic							-- seg7 digi selectors
	
); 
end LogicalStep_Lab3_top;

architecture Energy_Monitor of LogicalStep_Lab3_top is
--
-- Components Used
------------------------------------------------------------------- 

component compx4 is
	port(
		inputA		: in std_logic_vector(3 downto 0);
		inputB		: in std_logic_vector(3 downto 0);
		output		: out std_logic_vector(2 downto 0)--Groups the output of the comparator (A>B,A=B,A<B)
	);
end component compx4;

component TLU is
	port(
	
		systemState		:in std_logic_vector(2 downto 0);--Input from the comparator (A>B,A=B,A<B)
		button	:in std_logic_vector(3 downto 0);--Input from push buttons: 3(vacation mode), 2(Front door), 1(window), 0(back door)
		leds		:out std_logic_vector(7 downto 0) --0(furnace on), 1(system at temp, 2(A/C on), 3 (blower on), 4-6(doors and windows), 7 (vacation)
		
	);
end component TLU;

component mux is
   port (
			button  		: in std_logic;
			desired		: in std_logic_vector(3 downto 0);
			setTemp		: out std_logic_vector(3 downto 0)
        );
end component mux;	

component segment7_mux is
   port (
          clk        : in  std_logic := '0';
			 DIN2 		: in  std_logic_vector(6 downto 0);	
			 DIN1 		: in  std_logic_vector(6 downto 0);
			 DOUT			: out	std_logic_vector(6 downto 0);
			 DIG2			: out	std_logic;
			 DIG1			: out	std_logic
        );
end component segment7_mux;

component SevenSegment is port (
   
   hex	   :  in  std_logic_vector(3 downto 0);   -- The 4 bit data to be displayed
   
   sevenseg :  out std_logic_vector(6 downto 0)    -- 7-bit outputs to a 7-segment
); 
end component SevenSegment;
------------------------------------------------------------------
	
	
-- Create any signals, or temporary variables to be used
	
	signal inputB :	std_logic_vector(3 downto 0);--4 bit signal that will hold desired temp/vacation temp
	signal seg7_A :	std_logic_vector(6 downto 0);--7 bit signal to be displayed on left 7 segment
	signal seg7_B :	std_logic_vector(6 downto 0);--7 bit signal to be displayed on right 7 segment
	signal pb_bar:		std_logic_vector(3 downto 0);--4 bit signal to change passive high push buttons to passive low
	signal compareOut: std_logic_vector (2 downto 0);--3 bit signal to hold the result of the 4 bit comparator
-- Here the circuit begins

begin

pb_bar <= NOT(pb);
INST1: mux port map (pb_bar(3),sw(7 downto 4),inputB(3 downto 0)); --Multiplexer to choose between desired temp and vacation tmep

INST2: compx4 port map (sw(3 downto 0),inputB(3 downto 0), compareOut(2 downto 0)); --Instantiate 4 bit comparator to compare desired and current temp
--compareOut holds the output of the comparator (A>B,A=B,A<B)
INST3: TLU port map( compareOut(2 downto 0),pb_bar(3 downto 0),leds(7 downto 0));--Instantiate Energy Monitor and Control Logic for monitoring temperature
--Takes input from comparator and pushbuttons to be displayed on the LEDS
--LED: [0]-Furnace, [1]-At Desired Temp, [2]-AC, [3]-Blower, [4]-BDoor, [5]-Window, [6]-FDoor, [7]-Vacation Mode
INST4: SevenSegment port map (inputB,seg7_A);--Instantiate 7 segment decoder for decoding desired temp
INST5:SevenSegment port map(sw(3 downto 0), seg7_B); -- Instantiate another 7 segment decoder for decoding current temp
INST6: segment7_mux port map (clkin_50, seg7_B,seg7_A,seg7_data, seg7_char2, seg7_char1); --Instantiate 7 segment mux to display the current and desired temp on the 7 segment displays

 
end Energy_Monitor;

