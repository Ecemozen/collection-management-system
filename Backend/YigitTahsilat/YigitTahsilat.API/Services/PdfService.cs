using QuestPDF.Fluent;
using QuestPDF.Helpers;
using QuestPDF.Infrastructure;
using YigitTahsilat.API.Entities;

namespace YigitTahsilat.API.Services
{
    public class PdfService
    {
        public byte[] GenerateDebtReport(List<Debt> debts)
        {
            QuestPDF.Settings.License = LicenseType.Community;

            return Document.Create(container =>
            {
                container.Page(page =>
                {
                    page.Margin(30);

                    page.Header()
                        .Text("YiğitAkü Tahsilat Sistemi")
                        .FontSize(22)
                        .Bold();

                    page.Content()
                        .Column(column =>
                        {
                            column.Item().Text("Borç Raporu")
                                .FontSize(18)
                                .Bold();

                            column.Item().PaddingVertical(10);

                            column.Item().Table(table =>
                            {
                                table.ColumnsDefinition(columns =>
                                {
                                    columns.RelativeColumn(2);
                                    columns.RelativeColumn();
                                    columns.RelativeColumn();
                                    columns.RelativeColumn();
                                });

                                table.Header(header =>
                                {
                                    header.Cell().Text("Fatura");
                                    header.Cell().Text("Tutar");
                                    header.Cell().Text("Kalan");
                                    header.Cell().Text("Durum");
                                });

                                foreach (var debt in debts)
                                {
                                    table.Cell().Text(debt.InvoiceNumber);

                                    table.Cell().Text(
                                        debt.Amount.ToString("N2") + " ₺");

                                    table.Cell().Text(
                                        debt.RemainingAmount.ToString("N2") + " ₺");

                                    table.Cell().Text(debt.Status);
                                }
                            });
                        });

                    page.Footer()
                        .AlignCenter()
                        .Text(x =>
                        {
                            x.Span("Oluşturulma Tarihi: ");
                            x.Span(DateTime.Now.ToString("dd.MM.yyyy HH:mm"));
                        });
                });
            }).GeneratePdf();
        }
    }
}