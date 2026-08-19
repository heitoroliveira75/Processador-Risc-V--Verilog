module ctrl_execucao (
    input        CLOCK_50,
    input        reset,
    input        botao,
    input  [3:0] switches_n,
    output reg [3:0] n_capturado,
    output       clock_liberado
);

    reg rodando;


    reg [19:0] debounce_cnt;
    reg        botao_estavel;

    always @(posedge CLOCK_50) begin
        if (reset) begin
            rodando       <= 1'b0;
            n_capturado   <= 4'd0;
            debounce_cnt  <= 20'd0;
            botao_estavel <= 1'b0;
        end else begin

            // Lógica de debounce
            if (botao == 1'b1) begin
                // Botão solto — zera contador e flag
                debounce_cnt  <= 20'd0;
                botao_estavel <= 1'b0;
            end else begin
                // Botão pressionado — incrementa contador
                if (debounce_cnt == 20'd999_999) begin
                    // Estável por 20ms — confirma pressionamento
                    botao_estavel <= 1'b1;
                end else begin
                    debounce_cnt <= debounce_cnt + 20'd1;
                end
            end

            // Captura n quando botão confirmado e ainda não rodando
            if (botao_estavel && !rodando) begin
                n_capturado <= switches_n;
                rodando     <= 1'b1;
            end
        end
    end

    assign clock_liberado = rodando;

endmodule