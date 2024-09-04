module testbench;

// Clock and reset signals
reg clk;
reg dec_clk;
reg reset;
reg spi_clk;
reg spi_mosi;
reg spi_cs_n;
reg mic_data;

// Output signal (if any, replace 'output_signal' with the actual output of your DUT)
wire out;
wire mic_clk;

// Instantiate the DUT (Device Under Test)
top_module u_top_module (
    .clk(clk),
    .rst(reset),
    .spi_mosi(spi_mosi),
    .spi_cs_n(spi_cs_n),
    .mic_data(mic_data),
    .out(out),
    .mic_clk(mic_clk)
);

// Clock generation for clk (3.072 MHz)
initial begin
    clk = 0;
    forever #162.76 clk = ~clk; // Half period = 1 / (2 * 3.072 MHz) = 162.76 ns
end

// Clock generation for dec_clk (48 kHz)
initial begin
    dec_clk = 0;
    forever #10416.67 dec_clk = ~dec_clk; // Half period = 1 / (2 * 48 kHz) = 10416.67 ns
end



// Memory to store input data
reg input_data [0:262143]; // Adjust the size based on your input data length

// File handling for input and output
integer infile, outfile, c, outsigfile;
integer i;
// Initial block for reset and input signal generation
initial begin
    // Initialize reset
    reset = 1;
    spi_cs_n = 1;
    spi_mosi = 0;
    mic_data = 0;

    // Apply reset
    #1000;
    reset = 0;
    
    // SPI communication to write 8 to address 0 and 128 to address 1
    spi_cs_n = 0; // Select the SPI device

    // Write 8 to address 0
    write_to_spi(8'h00, 8'h08);
    spi_cs_n = 1;
    #1000;
    spi_cs_n = 0;
    // Write 128 to address 1
    write_to_spi(8'h01, 8'h80);

    spi_cs_n = 1; // Deselect the SPI device

    // Read input data from file and apply it to input_signal
    $readmemb("pdm_sine_wave_2_binary.txt", input_data);

    
    for (i = 0; i < 262144; i = i + 1) begin
        mic_data = input_data[i];
        @(posedge clk); // Apply input at the rising edge of clk
    end

    // Finish simulation
    #1000;
    $finish;
end

// Task to write data to SPI
task write_to_spi(input [7:0] addr, input [7:0] data);
    integer bit;
    begin
        // Send address (8 bits)
        for (bit = 7; bit >= 0; bit = bit - 1) begin
            spi_mosi = addr[bit];
            @(posedge spi_clk);
        end

        // Send data (8 bits)
        for (bit = 7; bit >= 0; bit = bit - 1) begin
            spi_mosi = data[bit];
            @(posedge spi_clk);
        end
    end
endtask

// Convert input data from -1 and 1 to 0 and 1
// initial begin
//     infile = $fopen("pdm_sine_wave_2.txt", "r");
//     outfile = $fopen("pdm_sine_wave_2_binary.txt", "w");
//     while (!$feof(infile)) begin
//         c = $fgetc(infile);
//         if (c == "-")
//             $fwrite(outfile, "0\n");
//         else if (c == "1")
//             $fwrite(outfile, "1\n");
//     end
//     $fclose(infile);
//     $fclose(outfile);
// end

// Dump waveforms for debugging
initial begin
    $dumpfile("tb_top_module.vcd");  // Name of the VCD file
    $dumpvars(0, testbench);         // Dump all variables in the testbench module
    $dumpvars(1, u_top_module);      // Dump all variables at the first level of the top_module
    $dumpvars(2, u_top_module.u_spi_port);  // Dump variables in the u_spi_port submodule
    $dumpvars(2, u_top_module.u_memory);    // Dump variables in the u_memory submodule
    $dumpvars(2, u_top_module.u_demux1to2); // Dump variables in the u_demux1to2 submodule
    $dumpvars(2, u_top_module.u_decimator); // Dump variables in the u_decimator submodule
    $dumpvars(2, u_top_module.u_filter);    // Dump variables in the u_filter submodule
    $dumpvars(2, u_top_module.u_i2s_bus);   // Dump variables in the u_i2s_bus submodule       // Dump all variables in the testbench module
end

// Monitor output signal and log changes
reg prev_output_signal;
// initial begin
//     prev_output_signal = 1'bx; // Initialize to an unknown value
//     outsigfile = $fopen("output_changes.txt", "w");
//     if (outsigfile == 0) begin
//         $display("Failed to open file for writing");
//         $finish;
//     end
// end

// always @(posedge clk) begin
//     if ($time > 1000 && $time < $time + 162.76) begin // Skip logging during reset
//         if (out !== prev_output_signal) begin
//             $fwrite(outsigfile, "%b\n", out);
//             prev_output_signal = out;
//         end
//     end
// end

// Close the file at the end of simulation
initial begin
    #100000; // Adjust the simulation end time as needed
    $fclose(outsigfile);
end

endmodule
