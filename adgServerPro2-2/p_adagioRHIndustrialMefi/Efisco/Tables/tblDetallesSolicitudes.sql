USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Efisco].[tblDetallesSolicitudes](
	[IDDetalleSolicitud] [int] IDENTITY(1,1) NOT NULL,
	[IDSolicitud] [int] NOT NULL,
	[Version] [nvarchar](10) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[Serie] [nvarchar](255) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[Folio] [nvarchar](255) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[NoCertificado] [nvarchar](255) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[Fecha] [datetime] NULL,
	[Subtotal] [decimal](18, 2) NULL,
	[Descuento] [decimal](18, 2) NULL,
	[Total] [decimal](18, 2) NULL,
	[Moneda] [nvarchar](255) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[MetodoPago] [nvarchar](255) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[LugarExpedicion] [nvarchar](255) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[EmisorRFC] [nvarchar](19) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[EmisorNombre] [nvarchar](255) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[EmisorRegimenFiscal] [nvarchar](255) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[ReceptorRFC] [nvarchar](255) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[ReceptorNombre] [nvarchar](255) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[UUID] [nvarchar](255) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[FechaTimbrado] [datetime] NULL,
	[RFCProvCertif] [nvarchar](255) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[SELLOCFD] [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[FechaPago] [datetime] NULL,
	[FechaInicial] [datetime] NULL,
	[FechaFinal] [datetime] NULL,
	[NumDiasPagados] [decimal](18, 2) NULL,
	[TotalPagados] [decimal](18, 2) NULL,
	[TotalDeRecepciones] [decimal](18, 2) NULL,
	[TotalDeducciones] [decimal](18, 2) NULL,
	[TotalOtros] [decimal](18, 2) NULL,
	[RegistroPatronal] [nvarchar](255) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[NumEmpleado] [nvarchar](255) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[Estatus] [nvarchar](255) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[FechaCancelacion] [datetime] NULL,
PRIMARY KEY CLUSTERED 
(
	[IDDetalleSolicitud] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [Efisco].[tblDetallesSolicitudes]  WITH CHECK ADD  CONSTRAINT [FK_Solicitud] FOREIGN KEY([IDSolicitud])
REFERENCES [Efisco].[tblSolicitudesCreadas] ([IDSolicitud])
GO
ALTER TABLE [Efisco].[tblDetallesSolicitudes] CHECK CONSTRAINT [FK_Solicitud]
GO
