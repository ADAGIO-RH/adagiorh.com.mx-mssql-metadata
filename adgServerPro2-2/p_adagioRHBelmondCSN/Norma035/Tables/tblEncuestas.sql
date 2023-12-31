USE [p_adagioRHBelmondCSN]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Norma035].[tblEncuestas](
	[IDEncuesta] [int] IDENTITY(1,1) NOT NULL,
	[FechaIni] [date] NULL,
	[FechaFin] [date] NULL,
	[IDTipoEncuesta] [int] NULL,
	[TodaEmpresa] [bit] NULL,
	[IDEntidad] [int] NULL,
	[Cantidad] [int] NULL,
	[FrecuenciaRecordatorioDias] [int] NULL,
	[EsAnonimo] [bit] NULL,
	[Estatus] [int] NULL,
 CONSTRAINT [Pk_Norma035tblEncuestas_IDEncuesta] PRIMARY KEY CLUSTERED 
(
	[IDEncuesta] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 20, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Norma035].[tblEncuestas]  WITH CHECK ADD  CONSTRAINT [Fk_Norma035TblEncuestas_Norma035TblCatTiposEncuestas_IDTipoEncuesta] FOREIGN KEY([IDTipoEncuesta])
REFERENCES [Norma035].[tblCatTiposEncuestas] ([IDTipoEncuesta])
GO
ALTER TABLE [Norma035].[tblEncuestas] CHECK CONSTRAINT [Fk_Norma035TblEncuestas_Norma035TblCatTiposEncuestas_IDTipoEncuesta]
GO
ALTER TABLE [Norma035].[tblEncuestas]  WITH CHECK ADD  CONSTRAINT [Fk_Norma035TblEncuestas_RHTblCatSucursales_IDSucursal] FOREIGN KEY([IDTipoEncuesta])
REFERENCES [RH].[tblCatSucursales] ([IDSucursal])
GO
ALTER TABLE [Norma035].[tblEncuestas] CHECK CONSTRAINT [Fk_Norma035TblEncuestas_RHTblCatSucursales_IDSucursal]
GO
