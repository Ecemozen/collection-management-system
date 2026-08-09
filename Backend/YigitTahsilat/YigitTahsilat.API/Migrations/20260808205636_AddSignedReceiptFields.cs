using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace YigitTahsilat.API.Migrations
{
    /// <inheritdoc />
    public partial class AddSignedReceiptFields : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.CreateIndex(
                name: "IX_Receipts_PaymentId",
                table: "Receipts",
                column: "PaymentId",
                unique: true);

            migrationBuilder.AddForeignKey(
                name: "FK_Receipts_Payments_PaymentId",
                table: "Receipts",
                column: "PaymentId",
                principalTable: "Payments",
                principalColumn: "Id",
                onDelete: ReferentialAction.Cascade);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_Receipts_Payments_PaymentId",
                table: "Receipts");

            migrationBuilder.DropIndex(
                name: "IX_Receipts_PaymentId",
                table: "Receipts");
        }
    }
}
