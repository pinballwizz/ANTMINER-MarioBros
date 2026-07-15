---------------------------------------------------------------------------------
--                          Mario Bros - AntMiner S9
--                              Code from gaz68
--
--                          Modified for AntMiner S9 
--                              by pinballwiz 
--                                24/06/2026
---------------------------------------------------------------------------------
-- Keyboard inputs :
--   5 : Add coin
--   2 : Start 2 players
--   1 : Start 1 player
--   LEFT Ctrl   : Jump
--   RIGHT arrow : Move Right
--   LEFT arrow  : Move Left
--   UP arrow    : Move Up
--   DOWN arrow  : Move Down
---------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.ALL;
use ieee.numeric_std.all;
---------------------------------------------------------------------------------
entity mariobros_antminer is
port(
	clock_50    : in std_logic;
   	I_RESET     : in std_logic;
	O_VIDEO_R	: out std_logic_vector(2 downto 0); 
	O_VIDEO_G	: out std_logic_vector(2 downto 0);
	O_VIDEO_B	: out std_logic_vector(1 downto 0);
	O_HSYNC		: out std_logic;
	O_VSYNC		: out std_logic;
	O_AUDIO_L 	: out std_logic;
	O_AUDIO_R 	: out std_logic;
   	ps2_clk     : in std_logic;
	ps2_dat     : inout std_logic;
	led         : out std_logic_vector(7 downto 0);
	aled        : out std_logic_vector(3 downto 0);
	joy         : in std_logic_vector(7 downto 0);
	dipsw       : in std_logic_vector(7 downto 0)
 );
end mariobros_antminer;
------------------------------------------------------------------------------
architecture struct of mariobros_antminer is

 signal clock_48    : std_logic;
 signal clock_36    : std_logic;
 signal clock_24    : std_logic;
 signal clock_18    : std_logic;
 signal clock_12    : std_logic;
 signal clock_9     : std_logic;
 --
 signal video_r     : std_logic_vector(2 downto 0);
 signal video_g     : std_logic_vector(2 downto 0);
 signal video_b     : std_logic_vector(1 downto 0);
 --
 signal video_ri    : std_logic_vector(5 downto 0);
 signal video_gi    : std_logic_vector(5 downto 0);
 signal video_bi    : std_logic_vector(5 downto 0);
 --
 signal M_HSYNC     : std_logic;
 signal M_VSYNC	    : std_logic;
 --
 signal h_blank     : std_logic;
 signal v_blank	    : std_logic;
 --
 signal video_r_x2  : std_logic_vector(5 downto 0);
 signal video_g_x2  : std_logic_vector(5 downto 0);
 signal video_b_x2  : std_logic_vector(5 downto 0);
 signal hsync_x2    : std_logic;
 signal vsync_x2    : std_logic;
 --
 signal reset       : std_logic;
 --
 signal oSND        : std_logic_vector(15 downto 0);
 signal dac_in      : std_logic_vector(15 downto 0);
 signal audio_pwm   : std_logic;
 --
 signal INP0        : std_logic_vector(7 downto 0);
 signal INP1        : std_logic_vector(7 downto 0);
 --
 signal kbd_intr        : std_logic;
 signal kbd_scancode    : std_logic_vector(7 downto 0);
 signal joy_BBBBFRLDU   : std_logic_vector(9 downto 0);
 --
 constant CLOCK_FREQ    : integer := 27E6;
 signal counter_clk     : std_logic_vector(25 downto 0);
 signal clock_4hz       : std_logic;
 signal AD              : std_logic_vector(15 downto 0);
 signal SND_ADDR        : std_logic_vector(11 downto 0);
 ---------------------------------------------------------------------------
component mariobros_clocks
port(
  clk_out1          : out    std_logic;
  clk_out2          : out    std_logic;
  clk_in1           : in     std_logic
 );
end component;
---------------------------------------------------------------------------
begin

 reset <= not I_RESET;
 aled(3 downto 0) <= "1111"; -- turn unused onboard leds off
---------------------------------------------------------------------------
-- Clocks

Clocks: mariobros_clocks
    port map (
        clk_in1   => clock_50,
        clk_out1  => clock_48,
        clk_out2  => clock_36
    );
---------------------------------------------------------------------------
-- Clocks Divide

process(clock_48)
begin
	if rising_edge(clock_48) then
		clock_24 <= not clock_24;
	end if;
end process;
--
process(clock_36)
begin
	if rising_edge(clock_36) then
		clock_18 <= not clock_18;
	end if;
end process;
--
process(clock_18)
begin
	if rising_edge(clock_18) then
		clock_9 <= not clock_9;
	end if;
end process;
---------------------------------------------------------------------------
-- input
 
 INP0  <= '1' & not joy_BBBBFRLDU(6) & not joy_BBBBFRLDU(5) & not joy_BBBBFRLDU(4) & '1' & '1' & not joy_BBBBFRLDU(2) & not joy_BBBBFRLDU(3);
 INP1  <= '1' & '1' & joy_BBBBFRLDU(7) & not joy_BBBBFRLDU(4) & '1' & '1' & not joy_BBBBFRLDU(2) & not joy_BBBBFRLDU(3);
---------------------------------------------------------------------------
-- Main

mariobros : entity work.mario_top
  port map (
 I_CLK_48M      => clock_48,
 I_RESETn       => I_RESET,
 I_ANLG_VOL     => "0000",
 I_SW1          => INP0, 
 I_SW2          => INP1, 
 I_DIPSW        => "00000000", 
 O_VGA_R        => video_r,
 O_VGA_G        => video_g,
 O_VGA_B        => video_b,
 O_HBLANK       => h_blank,
 O_VBLANK       => v_blank,
 O_VGA_HSYNCn   => M_HSYNC,
 O_VGA_VSYNCn   => M_VSYNC,
 SND_ADDR       => SND_ADDR,
 O_SOUND_DAT    => oSND,
 AD             => AD
   );
------------------------------------------------------------------------------
  video_ri <= video_r & video_r when h_blank = '0' and v_blank = '0' else "000000";
  video_gi <= video_g & video_g when h_blank = '0' and v_blank = '0' else "000000";
  video_bi <= video_b & video_b & video_b when h_blank = '0' and v_blank = '0' else "000000";
------------------------------------------------------------------------------
-- scan doubler

dblscan: entity work.scandoubler
	port map(
		clk_sys => clock_24,
		scanlines => "00",
		r_in   => video_ri,
		g_in   => video_gi,
		b_in   => video_bi,
		hs_in  => M_HSYNC,
		vs_in  => M_VSYNC,
		r_out  => video_r_x2,
		g_out  => video_g_x2,
		b_out  => video_b_x2,
		hs_out => hsync_x2,
		vs_out => vsync_x2
	);
-------------------------------------------------------------------------
-- vga output

	O_VIDEO_R 	<= video_r_x2(5 downto 3);
	O_VIDEO_G 	<= video_g_x2(5 downto 3);
	O_VIDEO_B 	<= video_b_x2(5 downto 4);
	O_HSYNC     <= hsync_x2;
	O_VSYNC     <= vsync_x2;
---------------------------------------------------------------
 -- Audio DAC

dac_in <= std_logic_vector(unsigned(oSND) + to_unsigned(16#8000#, 16)); -- snd convert

u_dac : entity work.dac
  generic map(
    msbi_g => 15
  )
port  map(
    clk_i   => clock_18,
    res_n_i => I_RESET,
    dac_i   => dac_in,
    dac_o   => audio_pwm
);

 O_AUDIO_L <= audio_pwm; 
 O_AUDIO_R <= audio_pwm;

------------------------------------------------------------------------------
-- get scancode from keyboard

keyboard : entity work.io_ps2_keyboard
port map (
  clk       => clock_9,
  kbd_clk   => ps2_clk,
  kbd_dat   => ps2_dat,
  interrupt => kbd_intr,
  scancode  => kbd_scancode
);
------------------------------------------------------------------------------
-- translate scancode to joystick

joystick : entity work.kbd_joystick
port map (
  clk         => clock_9,
  kbdint      => kbd_intr,
  kbdscancode => std_logic_vector(kbd_scancode), 
  joy_BBBBFRLDU  => joy_BBBBFRLDU 
);
------------------------------------------------------------------------------
-- debug

process(reset, clock_24)
begin
  if reset = '1' then
   clock_4hz <= '0';
   counter_clk <= (others => '0');
  else
    if rising_edge(clock_24) then
      if counter_clk = CLOCK_FREQ/8 then
        counter_clk <= (others => '0');
        clock_4hz <= not clock_4hz;
        led(7 downto 0) <= not AD(14 downto 7);
      else
        counter_clk <= counter_clk + 1;
      end if;
    end if;
  end if;
end process;
------------------------------------------------------------------------------
end struct;