module avalon (
    input wire clk,
    input wire resetn,
    output reg valid,
    input wire ready,
    output reg [7:0] data
);

// Valid (saída): Avisa o consumidor de dados que os dados na porta de dados estão válidos. 
// Só pode ficar em nível alto se o sinal ready estiver alto ou no ciclo seguinte ao que ready baixar.
// Ready (entrada): Aviso vindo do consumidor de dados de que ele está pronto para receber os dados. Ativo em nível alto.
// Data (saída): Dados a serem transmitidos. Só pode ocorrer transmissão quando tanto o sinal de valid quanto o de ready estiverem em nível alto. Permite atraso de um ciclo.

parameter IDLE = 3'b000,
          AGUARDAR_CICLO = 3'b001,
          ENVIAR_4 = 3'b010,
          ENVIAR_5 = 3'b011,
          ENVIAR_6 = 3'b100,
          DONE = 3'b101;  

reg[2:0] estado, prox_estado;

always @(posedge clk or posedge resetn) begin
    if (resetn) begin
        estado <= IDLE;
    end else begin
        estado <= prox_estado;
    end
end

always @(*) begin
    prox_estado = estado;
    case(estado)
        IDLE: begin
            if(ready) begin
                prox_estado = AGUARDAR_CICLO;
            end else begin
                prox_estado = IDLE;
            end
        end
        AGUARDAR_CICLO: begin
            prox_estado = ENVIAR_4;
        end
        ENVIAR_4: begin
            if(ready) begin
                prox_estado = ENVIAR_5;
            end else begin
                prox_estado = ENVIAR_4;
            end
        end
        ENVIAR_5: begin
            if(ready) begin
                prox_estado = ENVIAR_6;
            end else begin
                prox_estado = ENVIAR_5;
            end
        end
        ENVIAR_6: begin
            if(ready) begin
                prox_estado = DONE;
            end else begin
                prox_estado = ENVIAR_6;
            end
        end
        DONE: begin
            prox_estado = DONE;
        end
        default: begin
            prox_estado = IDLE;
        end
    endcase
end

always @(posedge clk or posedge resetn) begin
    if(resetn) begin
        valid <= 0;
        data <= 8'b0;
    end else begin
        case(estado)
            IDLE, AGUARDAR_CICLO, DONE: begin
                valid <= 0;
                data <= 8'dx;
            end
            ENVIAR_4: begin
                valid <= 1;
                data <= 8'd4; // Envia o dado 4
            end
            ENVIAR_5: begin
                valid <= 1;
                data <= 8'd5; // Envia o dado 5
            end
            ENVIAR_6: begin
                valid <= 1;
                data <= 8'd6; // Envia o dado 6
            end
            default: begin
                valid <= 0;
                data <= 8'dx;
            end
        endcase
    end
end

endmodule

