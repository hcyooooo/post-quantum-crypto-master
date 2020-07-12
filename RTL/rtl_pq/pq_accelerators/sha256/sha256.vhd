--//////////////////////////////////////////////////////////////////////////////////
--// Company: Technical University of Munich
--// Engineer: Tim Fritzmann
--// 
--// Create Date: 01/27/2020
--// Module Name: sha256
--// Project Name: Post-Quantum Cryptography
--// 
--//////////////////////////////////////////////////////////////////////////////////


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity sha256 is
	port(	clk : in std_logic;
			rst : in std_logic;
			
			-- controll inputs
			gen_hash : in std_logic;						-- starts generating produkt when switched to 1
			load_hash : in std_logic;						-- when 1 loads hash_in to internal signal h (gen_hash must be 0)
			
			-- variable inputs
			hash_in : in std_logic_vector(255 downto 0);	-- input for load_hash
			msg : in std_logic_vector(511 downto 0);		-- message block that the hash should be generated for
			
			-- outputs
			block_ready : out std_logic;					-- generation for current message block finished
			hash_out : out std_logic_vector(255 downto 0)	-- actuell output
			);
end sha256;

architecture Behavioral of sha256 is
	signal count : unsigned(5 downto 0);
	
	type registers is array(15 downto 0) of unsigned(31 downto 0);
	
	signal reg : registers;
	
	signal w_t : std_logic_vector(31 downto 0);
	
	type lookup is array(63 downto 0) of std_logic_vector(31 downto 0);
	signal k_lookup : lookup;
	
	signal k_t : std_logic_vector(31 downto 0);
	
	type sha_1_array is array(7 downto 0) of std_logic_vector(31 downto 0);
		
	signal abc : sha_1_array;
		
	signal ch : unsigned(31 downto 0);
	signal maj : unsigned(31 downto 0);
		
	signal sum_0 : unsigned(31 downto 0);
	signal sum_1 : unsigned(31 downto 0);
		
	signal sigma_0 : unsigned(31 downto 0);
	signal sigma_1 : unsigned(31 downto 0);
	
	signal T_1 : unsigned(31 downto 0);
	signal T_2 :unsigned(31 downto 0);
	
	signal h : sha_1_array;
	
	type state_types is(idle,
						wait_for_hash,
						finished
						);
	
	type sha256_comb IS record
		state : state_types;
		
		rst_count : std_logic;
		
		step_shift : std_logic;
		load_shift : std_logic;
		
		abc_load : std_logic;
		abc_ready : std_logic;
		
		block_ready : std_logic;
	end record;
	
	signal r, r_next : sha256_comb;
begin
	counter : process(clk, r, count)
	begin
		if rising_edge(clk) then
--			if r.rst_count = '1' then
			if r.rst_count = '1' or r.state = idle then
				count <= (others => '0');
			else 
				count <= count + "1";
			end if;
		end if;
	end process;
	
	sigma_0 <= (reg(14) ror 7) xor (reg(14) ror 18) xor (reg(14) srl 3);
	sigma_1 <= (reg(1) ror 17) xor (reg(1) ror 19) xor (reg(1) srl 10);
	
	w_t_shift_reg : for i in 15 downto 0 generate
		zero : if i = 0 generate
			reg_pro : process(clk, rst, r, msg)
			begin
				if rising_edge(clk) then
					if rst = '1' then
						reg(i) <= (others => '0');
					else
						if r.load_shift = '1' then
							reg(i) <= unsigned(msg((i + 1) * 32 - 1 downto i * 32));
						else
							if r.step_shift = '1' then
								reg(i) <= sigma_1 + reg(6) + sigma_0 + reg(15);
							end if;
						end if;
					end if;
				end if;
			end process;
		end generate;
		non_zero : if i /= 0 generate
			reg_pro : process(clk, rst, r)
			begin
				if rising_edge(clk) then
					if rst = '1' then
						reg(i) <= (others => '0');
					else
						if r.load_shift = '1' then
							reg(i) <= unsigned(msg((i + 1) * 32 - 1 downto i * 32));
						else
							if r.step_shift = '1' then
								reg(i) <= reg(i-1);
							end if;
						end if;
					end if;
				end if;
			end process;
		end generate;
	end generate;
	
	w_t <= std_logic_vector(reg(15));
	
	k_lookup <= (X"c67178f2", X"bef9a3f7", X"a4506ceb", X"90befffa", X"8cc70208", X"84c87814", X"78a5636f", X"748f82ee", 
	                 X"682e6ff3", X"5b9cca4f", X"4ed8aa4a", X"391c0cb3", X"34b0bcb5", X"2748774c", X"1e376c08", X"19a4c116", 
	                 X"106aa070", X"f40e3585", X"d6990624", X"d192e819", X"c76c51a3", X"c24b8b70", X"a81a664b", X"a2bfe8a1", 
	                 X"92722c85", X"81c2c92e", X"766a0abb", X"650a7354", X"53380d13", X"4d2c6dfc", X"2e1b2138", X"27b70a85", 
	                 X"14292967", X"06ca6351", X"d5a79147", X"c6e00bf3", X"bf597fc7", X"b00327c8", X"a831c66d", X"983e5152", 
	                 X"76f988da", X"5cb0a9dc", X"4a7484aa", X"2de92c6f", X"240ca1cc", X"0fc19dc6", X"efbe4786", X"e49b69c1", 
	                 X"c19bf174", X"9bdc06a7", X"80deb1fe", X"72be5d74", X"550c7dc3", X"243185be", X"12835b01", X"d807aa98", 
	                 X"ab1c5ed5", X"923f82a4", X"59f111f1", X"3956c25b", X"e9b5dba5", X"b5c0fbcf", X"71374491", X"428a2f98");
	
	k_t <= k_lookup(to_integer(count));
	
	ch <= 	(unsigned(abc(4)) and unsigned(abc(5))) xor 
			(not(unsigned(abc(4))) and unsigned(abc(6)));
	
	maj <= 	(unsigned(abc(0)) and unsigned(abc(1))) xor 
			(unsigned(abc(0)) and unsigned(abc(2))) xor 
			(unsigned(abc(1)) and unsigned(abc(2)));
	
	sum_0 <= (unsigned(abc(0)) ror 2) xor (unsigned(abc(0)) ror 13) xor (unsigned(abc(0)) ror 22);
	sum_1 <= (unsigned(abc(4)) ror 6) xor (unsigned(abc(4)) ror 11) xor (unsigned(abc(4)) ror 25);
	
	T_1 <= unsigned(abc(7)) + sum_1 + ch + unsigned(k_t) + unsigned(w_t);
	T_2 <= sum_0 + maj;
	
	abcde_fifos : process(clk, rst, abc, h, r, T_1, T_2)
	begin
		if rising_edge(clk) then
			if rst = '1'then
				abc <= (others => (others => '0'));
			else
				if r.abc_load = '1' then
					abc <= h;
				else
					abc(0) <= std_logic_vector(T_1 + T_2);
					abc(1) <= abc(0);
					abc(2) <= abc(1);
					abc(3) <= abc(2);
					abc(4) <= std_logic_vector(unsigned(abc(3)) + T_1);
					abc(5) <= abc(4);
					abc(6) <= abc(5);
					abc(7) <= abc(6);
				end if;
			end if;
		end if;
	end process;
	
	reg_control : process(clk, rst, r, r_next)
	begin
		if rising_edge(clk) then
			if rst = '1' then
				r.state <= idle;
					
				r.rst_count <= '0';
				
				r.step_shift <= '0';
				r.load_shift <= '0';
				
				r.abc_load <= '0';
				r.abc_ready <= '0';
				
				r.block_ready<= '0';
			else
				r <= r_next;
			end if;
		end if;
	end process;
	
	com_control : process(r, count, gen_hash)
		variable v : sha256_comb;
	begin
		v := r;
		
		v.block_ready := r.abc_ready;
		
		v.rst_count := '0';
		v.abc_load := '0';
		v.load_shift := '0';
		
		v.abc_ready := '0';
		v.step_shift := '0';
		case r.state is
			when idle =>
				if gen_hash = '1' then
					v.rst_count := '1';
					v.load_shift := '1';
					v.abc_load := '1';
					v.state := wait_for_hash;
				end if;
			when wait_for_hash =>
				v.step_shift := '1';
				if count = 63 then
					v.abc_ready := '1';
					v.state := finished;
				end if;
			when finished =>
				if r.block_ready = '0' then
					v.block_ready := '1';
				else
					v.state := idle;
				end if;
		end case;
		
		r_next <= v;
	end process;
	
	finish : process(clk, rst, abc, h, r)
	begin
		if rising_edge(clk) then
			if rst = '1' then
				h(0) <= x"6a09e667";
				h(1) <= x"bb67ae85";
				h(2) <= x"3c6ef372";
				h(3) <= x"a54ff53a";
				h(4) <= x"510e527f";
				h(5) <= x"9b05688c";
				h(6) <= x"1f83d9ab";
				h(7) <= x"5be0cd19";
			else
				if load_hash = '1' then
					h(0) <= hash_in(255 downto 224);
					h(1) <= hash_in(223 downto 192);
					h(2) <= hash_in(191 downto 160);
					h(3) <= hash_in(159 downto 128);
					h(4) <= hash_in(127 downto 96);
					h(5) <= hash_in(95 downto 64);
					h(6) <= hash_in(63 downto 32);
					h(7) <= hash_in(31 downto 0);
				elsif r.abc_ready = '1' then
					h(0) <= std_logic_vector(unsigned(h(0)) + unsigned(abc(0)));
					h(1) <= std_logic_vector(unsigned(h(1)) + unsigned(abc(1)));
					h(2) <= std_logic_vector(unsigned(h(2)) + unsigned(abc(2)));
					h(3) <= std_logic_vector(unsigned(h(3)) + unsigned(abc(3)));
					h(4) <= std_logic_vector(unsigned(h(4)) + unsigned(abc(4)));
					h(5) <= std_logic_vector(unsigned(h(5)) + unsigned(abc(5)));
					h(6) <= std_logic_vector(unsigned(h(6)) + unsigned(abc(6)));
					h(7) <= std_logic_vector(unsigned(h(7)) + unsigned(abc(7)));
				end if;
			end if;
		end if;
	end process;
	
	hash_out <= h(0) & h(1) & h(2) & h(3) & h(4) & h(5) & h(6) & h(7);
	block_ready <= r.block_ready;
end Behavioral;
