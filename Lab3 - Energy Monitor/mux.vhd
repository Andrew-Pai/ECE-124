library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;


-- ****************************************************************************
-- *  Entity                                                                  *
-- ****************************************************************************

entity mux is
   port (
			button  		: in std_logic;--Vacation button
			desired		: in std_logic_vector(3 downto 0);
			setTemp		: out std_logic_vector(3 downto 0)
        );
end entity mux;

-- *****************************************************************************
-- *  Architecture                                                             *
-- *****************************************************************************

architecture syn of mux is
	

   
begin

with button select
setTemp <= desired when '0',--desired temp from switch
			"0100" when '1',--Default vacation temp
			"0000" when others;

				

	

end  syn;
