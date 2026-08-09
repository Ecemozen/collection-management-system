using AutoMapper;
using YigitTahsilat.API.DTOs.Customer;
using YigitTahsilat.API.DTOs.Debt;
using YigitTahsilat.API.DTOs.FeeType;
using YigitTahsilat.API.DTOs.Payment;
using YigitTahsilat.API.Entities;
using YigitTahsilat.API.DTOs.Receipt;


namespace YigitTahsilat.API.Mappings
{
    public class MappingProfile : Profile
    {
        public MappingProfile()
        {
            // Customer Mappings
            CreateMap<Customer, CustomerDto>().ReverseMap();
            CreateMap<Customer, CreateCustomerDto>().ReverseMap();
            CreateMap<Customer, UpdateCustomerDto>().ReverseMap();
            CreateMap<Customer, CustomerListDto>().ReverseMap();

            // Debt Mappings
            CreateMap<Debt, DebtDto>().ReverseMap();
            CreateMap<Debt, CreateDebtDto>().ReverseMap();
            CreateMap<Debt, UpdateDebtDto>().ReverseMap();

            // Payment Mappings
            CreateMap<Payment, PaymentDto>().ReverseMap();
            CreateMap<Payment, CreatePaymentDto>().ReverseMap();
            CreateMap<Payment, UpdatePaymentDto>().ReverseMap();

            // FeeType Mappings
            CreateMap<FeeType, FeeTypeDto>().ReverseMap();
            CreateMap<FeeType, CreateFeeTypeDto>().ReverseMap();
            CreateMap<FeeType, UpdateFeeTypeDto>().ReverseMap();
            CreateMap<FeeType, FeeTypeListDto>().ReverseMap();

            // Receipt Mappings
            CreateMap<Receipt, ReceiptDto>().ReverseMap();
            CreateMap<Receipt, CreateReceiptDto>().ReverseMap();
            CreateMap<Receipt, UpdateReceiptDto>().ReverseMap();
            CreateMap<Receipt, ReceiptListDto>().ReverseMap();
        }
    }
}