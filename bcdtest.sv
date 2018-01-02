module bcdtest(input [15:0] A, B,
                output [15:0] S,
                output CO);
    logic C1, C2, C3, C4;
    bcd_adder b1(.IN_A(A[3:0]),
                .IN_B(B[3:0]),
                .CIN(1'b0),
                .COUT(C1),
                .SUM(S[3:0]));
    bcd_adder b2(.IN_A(A[7:4]),
                .IN_B(B[7:4]),
                .CIN(C1),
                .COUT(C2),
                .SUM(S[7:4]));
    bcd_adder b3(.IN_A(A[11:8]),
                .IN_B(B[11:8]),
                .CIN(C2),
                .COUT(C3),
                .SUM(S[11:8]));
    bcd_adder b4(.IN_A(A[15:12]),
                .IN_B(B[15:12]),
                .CIN(C3),
                .COUT(C4),
                .SUM(S[15:12]));
    assign CO = C4;
endmodule 