USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Nomina].[tblDevolucionesCajaAhorro](
	[IDDevolucionesCajaAhorro] [int] IDENTITY(1,1) NOT NULL,
	[IDCajaAhorro] [int] NOT NULL,
	[Monto] [decimal](18, 2) NOT NULL,
	[IDPeriodo] [int] NOT NULL,
	[IDUsuario] [int] NOT NULL,
	[FechaHora] [datetime] NOT NULL,
 CONSTRAINT [Pk_NominaTblDevolucionesCajaAhorro_IDDevolucionesCajaAhorro] PRIMARY KEY CLUSTERED 
(
	[IDDevolucionesCajaAhorro] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_NominatblDevolucionesCajaAhorro_IDCajaAhorro] ON [Nomina].[tblDevolucionesCajaAhorro]
(
	[IDCajaAhorro] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_NominatblDevolucionesCajaAhorro_IDPeriodo] ON [Nomina].[tblDevolucionesCajaAhorro]
(
	[IDPeriodo] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
ALTER TABLE [Nomina].[tblDevolucionesCajaAhorro] ADD  CONSTRAINT [D_NominaTblDevolucionesCajaAhorro_FechaHora]  DEFAULT (getdate()) FOR [FechaHora]
GO
ALTER TABLE [Nomina].[tblDevolucionesCajaAhorro]  WITH CHECK ADD  CONSTRAINT [Fk_NominaTblDevolucionesCajaAhorro_IDCajaAhorro] FOREIGN KEY([IDCajaAhorro])
REFERENCES [Nomina].[tblCajaAhorro] ([IDCajaAhorro])
GO
ALTER TABLE [Nomina].[tblDevolucionesCajaAhorro] CHECK CONSTRAINT [Fk_NominaTblDevolucionesCajaAhorro_IDCajaAhorro]
GO
ALTER TABLE [Nomina].[tblDevolucionesCajaAhorro]  WITH CHECK ADD  CONSTRAINT [Fk_NominaTblDevolucionesCajaAhorro_IDPeriodo] FOREIGN KEY([IDPeriodo])
REFERENCES [Nomina].[tblCatPeriodos] ([IDPeriodo])
GO
ALTER TABLE [Nomina].[tblDevolucionesCajaAhorro] CHECK CONSTRAINT [Fk_NominaTblDevolucionesCajaAhorro_IDPeriodo]
GO
ALTER TABLE [Nomina].[tblDevolucionesCajaAhorro]  WITH CHECK ADD  CONSTRAINT [Fk_NominaTblDevolucionesCajaAhorro_IDUsuario] FOREIGN KEY([IDUsuario])
REFERENCES [Seguridad].[tblUsuarios] ([IDUsuario])
GO
ALTER TABLE [Nomina].[tblDevolucionesCajaAhorro] CHECK CONSTRAINT [Fk_NominaTblDevolucionesCajaAhorro_IDUsuario]
GO
