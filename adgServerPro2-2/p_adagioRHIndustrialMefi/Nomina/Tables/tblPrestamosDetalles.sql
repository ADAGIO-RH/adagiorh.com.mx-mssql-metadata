USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Nomina].[tblPrestamosDetalles](
	[IDPrestamoDetalle] [int] IDENTITY(1,1) NOT NULL,
	[IDPrestamo] [int] NOT NULL,
	[IDPeriodo] [int] NULL,
	[MontoCuota] [decimal](18, 2) NULL,
	[FechaPago] [date] NOT NULL,
	[Receptor] [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[IDUsuario] [int] NULL,
 CONSTRAINT [PK_NominatblPrestamosDetalles_IDPrestamoDetalle] PRIMARY KEY CLUSTERED 
(
	[IDPrestamoDetalle] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_NominatblPrestamosDetalles_FechaPago] ON [Nomina].[tblPrestamosDetalles]
(
	[FechaPago] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_NominatblPrestamosDetalles_IDPeriodo] ON [Nomina].[tblPrestamosDetalles]
(
	[IDPeriodo] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_NominatblPrestamosDetalles_IDPrestamo] ON [Nomina].[tblPrestamosDetalles]
(
	[IDPrestamo] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
ALTER TABLE [Nomina].[tblPrestamosDetalles]  WITH CHECK ADD  CONSTRAINT [FK_NominatblPrestamo_NominatblPrestamosDetalles_IDPrestamo] FOREIGN KEY([IDPrestamo])
REFERENCES [Nomina].[tblPrestamos] ([IDPrestamo])
GO
ALTER TABLE [Nomina].[tblPrestamosDetalles] CHECK CONSTRAINT [FK_NominatblPrestamo_NominatblPrestamosDetalles_IDPrestamo]
GO
ALTER TABLE [Nomina].[tblPrestamosDetalles]  WITH CHECK ADD  CONSTRAINT [FK_NominaTblPrestamosDetalle_SeguridadTblUsuarios_IDUsuario] FOREIGN KEY([IDUsuario])
REFERENCES [Seguridad].[tblUsuarios] ([IDUsuario])
GO
ALTER TABLE [Nomina].[tblPrestamosDetalles] CHECK CONSTRAINT [FK_NominaTblPrestamosDetalle_SeguridadTblUsuarios_IDUsuario]
GO
