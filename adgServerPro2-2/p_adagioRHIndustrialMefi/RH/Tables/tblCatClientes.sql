USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [RH].[tblCatClientes](
	[IDCliente] [int] IDENTITY(1,1) NOT NULL,
	[GenerarNoNomina] [bit] NULL,
	[LongitudNoNomina] [int] NULL,
	[Prefijo] [varchar](10) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[NombreComercial] [App].[XLName] NULL,
	[Codigo] [varchar](20) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[PathReciboNomina] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[PathReciboNominaNoTimbrado] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[Traduccion] [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
 CONSTRAINT [PK_tblCatClientes_IDCliente] PRIMARY KEY CLUSTERED 
(
	[IDCliente] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
