using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace YigitTahsilat.API.Migrations
{
    /// <inheritdoc />
    public partial class AddBankNameToPayment : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "BankName",
                table: "Payments");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<string>(
                name: "BankName",
                table: "Payments",
                type: "nvarchar(max)",
                nullable: true);
        }
    }
}
