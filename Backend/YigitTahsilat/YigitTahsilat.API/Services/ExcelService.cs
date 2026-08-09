using ClosedXML.Excel;
using YigitTahsilat.API.Entities;

namespace YigitTahsilat.API.Services
{
    public class ExcelService
    {
        public byte[] GenerateDebtReport(List<Debt> debts)
        {
            using var workbook = new XLWorkbook();

            var worksheet = workbook.Worksheets.Add("Borçlar");

            worksheet.Cell(1, 1).Value = "Fatura No";
            worksheet.Cell(1, 2).Value = "Borç";
            worksheet.Cell(1, 3).Value = "Kalan";
            worksheet.Cell(1, 4).Value = "Durum";

            int row = 2;

            foreach (var debt in debts)
            {
                worksheet.Cell(row, 1).Value = debt.InvoiceNumber;
                worksheet.Cell(row, 2).Value = debt.Amount;
                worksheet.Cell(row, 3).Value = debt.RemainingAmount;
                worksheet.Cell(row, 4).Value = debt.Status;

                row++;
            }

            worksheet.Columns().AdjustToContents();

            using var stream = new MemoryStream();

            workbook.SaveAs(stream);

            return stream.ToArray();
        }
    }
}