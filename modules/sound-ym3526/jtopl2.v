/*  This file is part of JTOPL.

    JTOPL is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    JTOPL is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with JTOPL.  If not, see <http://www.gnu.org/licenses/>.

    Author: Jose Tejada Gomez. Twitter: @topapate
    Version: 1.0
    Date: 10-10-2021

    */

module jtopl2(
    input  wire                rst,        // rst should be at least 6 clk&cen cycles long
    input  wire                clk,        // CPU clock
    input  wire                cen,        // optional clock enable, it not needed leave as 1'b1
    input  wire         [ 7:0] din,
    input  wire                addr,
    input  wire                cs_n,
    input  wire                wr_n,
    output wire         [ 7:0] dout,
    output wire                irq_n,
    // combined output
    output wire signed  [15:0] snd,
    output wire                sample
);

    `define JTOPL2
    jtopl #(.OPL_TYPE(2)) u_base(
        .rst    ( rst       ),
        .clk    ( clk       ),
        .cen    ( cen       ),
        .din    ( din       ),
        .addr   ( addr      ),
        .cs_n   ( cs_n      ),
        .wr_n   ( wr_n      ),
        .dout   ( dout      ),
        .irq_n  ( irq_n     ),
        .snd    ( snd       ),
        .sample ( sample    )
    );

endmodule