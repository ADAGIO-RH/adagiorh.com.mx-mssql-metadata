USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Enrutamiento].[tblAutorizacionUnidadProceso](
	[IDAutorizacionUnidadProceso] [int] IDENTITY(1,1) NOT NULL,
	[IDRutaUnidadProceso] [int] NOT NULL,
	[IDSecuencia] [int] NOT NULL,
	[IDUsuario] [int] NOT NULL,
	[Autorizado] [int] NULL,
	[FechaHoraAutorizacion] [datetime] NULL,
	[Observacion] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
 CONSTRAINT [PK_EnrutamientoTblAutorizacionUnidadProceso_IDAutorizacionUnidadProceso] PRIMARY KEY CLUSTERED 
(
	[IDAutorizacionUnidadProceso] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [Enrutamiento].[tblAutorizacionUnidadProceso]  WITH CHECK ADD  CONSTRAINT [FK_EnrutamientotblRutaUnidadProceso_EnrutamientotblAutorizacionUnidadProceso_IDRutaUnidadProceso] FOREIGN KEY([IDRutaUnidadProceso])
REFERENCES [Enrutamiento].[tblRutaUnidadProceso] ([IDRutaUnidadProceso])
GO
ALTER TABLE [Enrutamiento].[tblAutorizacionUnidadProceso] CHECK CONSTRAINT [FK_EnrutamientotblRutaUnidadProceso_EnrutamientotblAutorizacionUnidadProceso_IDRutaUnidadProceso]
GO
