USE [p_adagioRHElPro]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Facturacion].[tblCatConfigEmpresa](
	[IDConfigEmpresa] [int] IDENTITY(1,1) NOT NULL,
	[IDEmpresa] [int] NOT NULL,
	[Usuario] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AI NOT NULL,
	[Password] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AI NOT NULL,
	[PasswordKey] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AI NOT NULL,
	[Token] [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[TieneCertificado] [bit] NULL,
 CONSTRAINT [PK_FacturaciontblCatConfigEmpresa_IDConfigEmpresa] PRIMARY KEY CLUSTERED 
(
	[IDConfigEmpresa] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [Facturacion].[tblCatConfigEmpresa]  WITH CHECK ADD  CONSTRAINT [FK_RHtblEmpresa_FacturaciontblCatConfigEmpresa_IDEmpresa] FOREIGN KEY([IDEmpresa])
REFERENCES [RH].[tblEmpresa] ([IdEmpresa])
GO
ALTER TABLE [Facturacion].[tblCatConfigEmpresa] CHECK CONSTRAINT [FK_RHtblEmpresa_FacturaciontblCatConfigEmpresa_IDEmpresa]
GO
