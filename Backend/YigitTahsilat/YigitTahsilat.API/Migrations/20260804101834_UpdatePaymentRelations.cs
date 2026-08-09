using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace YigitTahsilat.API.Migrations
{
    /// <inheritdoc />
    public partial class UpdatePaymentRelations : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.RenameColumn(
                name: "StudentId",
                table: "Payments",
                newName: "DebtId");

            migrationBuilder.AddColumn<string>(
                name: "Description",
                table: "Payments",
                type: "nvarchar(max)",
                nullable: false,
                defaultValue: "");

            migrationBuilder.CreateIndex(
                name: "IX_Payments_DebtId",
                table: "Payments",
                column: "DebtId");

            migrationBuilder.CreateIndex(
                name: "IX_Payments_FeeTypeId",
                table: "Payments",
                column: "FeeTypeId");

            migrationBuilder.AddForeignKey(
                name: "FK_Payments_Debts_DebtId",
                table: "Payments",
                column: "DebtId",
                principalTable: "Debts",
                principalColumn: "Id",
                onDelete: ReferentialAction.Cascade);

            migrationBuilder.AddForeignKey(
                name: "FK_Payments_FeeTypes_FeeTypeId",
                table: "Payments",
                column: "FeeTypeId",
                principalTable: "FeeTypes",
                principalColumn: "Id",
                onDelete: ReferentialAction.Cascade);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_Payments_Debts_DebtId",
                table: "Payments");

            migrationBuilder.DropForeignKey(
                name: "FK_Payments_FeeTypes_FeeTypeId",
                table: "Payments");

            migrationBuilder.DropIndex(
                name: "IX_Payments_DebtId",
                table: "Payments");

            migrationBuilder.DropIndex(
                name: "IX_Payments_FeeTypeId",
                table: "Payments");

            migrationBuilder.DropColumn(
                name: "Description",
                table: "Payments");

            migrationBuilder.RenameColumn(
                name: "DebtId",
                table: "Payments",
                newName: "StudentId");
        }
    }
}
