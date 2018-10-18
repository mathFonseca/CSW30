library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity toplevel is
	port(
			clk : in std_logic;
			rst : in std_logic;
			instr : out unsigned(15 downto 0);
			saida_ula : out unsigned(15 downto 0)
		);
end entity;

architecture a_toplevel of toplevel is
	component proto_uc_jump is
		port(
				clk : in std_logic;
				pc_rst : in std_logic;
				pc_wr_en : in std_logic;
				jump_flag : in std_logic;
				pc_data_in : in unsigned(6 downto 0);
				pc_data_out : out unsigned(6 downto 0)
	 	);	
	end component proto_uc_jump;

	component rom is
		port( 
				clk : in std_logic;
				endereco : in unsigned(6 downto 0);
				dado : out unsigned(15 downto 0)
		);
	end component rom;

	component maquina_estados is
	 	port(   
	 			clk : in std_logic;
				rst : in std_logic;
				estado: out unsigned(1 downto 0)
	 	);
	end component maquina_estados;

	component unidade_de_controle is
	  	port (
				opcode 	    		: in unsigned(3 downto 0);
  				jump_flag			: out std_logic;
  				reg_wr_en			: out std_logic;
  				update_pc			: out std_logic;
  				mux_reg_flag		: out std_logic;
  				mux_immediate_flag	: out std_logic;
  				maquina_de_estados	: in unsigned(1 downto 0);
  				operation_ula		: out unsigned(1 downto 0)
  		);
	end component unidade_de_controle; 

	component banco_reg is
		port(
				data: 						in unsigned(15 downto 0); 	--Dado para write.
				read_data_1, read_data_2: 	out unsigned(15 downto 0); 	-- Read data 1 e 2
				clk: 						in std_logic; --Clock universal
				rst: 						in std_logic; --Reset universal
				read_reg_1: 				in unsigned(3 downto 0); -- Read register 1
				read_reg_2: 				in unsigned(3 downto 0); -- Read register 2
				write_reg:					in unsigned(3 downto 0); -- Write register
				en_write:					in std_logic  -- Enable write
		);
	end component banco_reg;

	component mux2x1_4bits is
		 port (
				entrada01, entrada02: 	in unsigned(3 downto 0);
				enable:					in std_logic;
				seletor:				in std_logic;
				saida:					out unsigned(3 downto 0)
		);
	end component mux2x1_4bits;

	component ula is
		port(
				seletor: 				in unsigned(1 downto 0);
				entrada01, entrada02: 	in unsigned(15 downto 0);
				saida_ula: 				out unsigned(15 downto 0);
				saida_maior: 			out std_logic
			);
	end component ula;

	component barramento is
	port (
			instr: in unsigned(15 downto 0);
			opcode: out unsigned(3 downto 0);
			src: out unsigned(3 downto 0);
			dest: out unsigned(3 downto 0);
			end_jump: out unsigned(5 downto 0);
			immediate: out unsigned(7 downto 0)
		);
	end component barramento;
	
	signal data_out_s, endereco_s, endereco_jump: unsigned(6 downto 0);
	signal instr_s, saida_ula_s: unsigned(15 downto 0);
	signal estado_s, pc_wr_en, jump_flag, erro_flag, enable_mux: std_logic;
	signal opcode: unsigned(3 downto 0);
	signal src: unsigned(3 downto 0);
	signal dest: unsigned(3 downto 0);
	signal immediate: unsigned(7 downto 0)

begin

	proto_uc_jump_s: proto_uc_jump port map (
						pc_data_out => endereco_s,
						clk 	 => clk,
			 			pc_rst 	 => rst,
						pc_wr_en => pc_wr_en,
						jump_flag => jump_flag,
						pc_data_in => endereco_jump
	);

	rom_s:		rom port map (
						clk 	 => clk,
			 			endereco => endereco_s,
						dado	 => instr_s
	);

	fsm_s:		maquina_estados port map (
						clk 	=> clk,
						rst 	=> rst,
						estado 	=> estado_s
	);

	uc:			unidade_de_controle port map (
						opcode => opcode,
						jump_flag => jump_flag,
						reg_wr_en => reg_wr_en,
						update_pc => pc_wr_en,
						mux_reg_flag => mux_reg,
						mux_immediate_flag => mux_immediate,
						maquina_de_estados => estado_s,
						operation_ula => operation_ula
	);

	barramento: barramento port map (
						instr => instr_s,
						opcode => opcode,
						src => src,
						dest => dest,
						end_jump => endereco_jump,
						immediate => immediate
	);

	mux_reg: 	mux2x1_4bits port map (
						entrada01 => dest,
						entrada02 => zero,
						enable => enable_mux,
						seletor => mux_reg_flag,
						saida => end_reg_2
	);

	mux_immediate: mux2x1_4bits port map (
						entrada01 => data_reg_1,
						entrada02 => immediate,
						enable => enable_mux,
						seletor => mux_immediate_flag,
						saida => entrada01_ula
	);

	ula_s:		ula port map (
						seletor => operation_ula,
						entrada01 => entrada01_ula,
						entrada02 => entrada02_ula,
						saida_ula => saida_ula_s
						saida_maior => saida_maior_s
	);


	instr <= instr_s; -




	
end architecture a_toplevel;