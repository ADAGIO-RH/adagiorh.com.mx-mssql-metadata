USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Intranet].[tblSolicitudesPrestamos](
	[IDSolicitudPrestamo] [int] IDENTITY(1,1) NOT NULL,
	[IDEmpleado] [int] NOT NULL,
	[IDTipoPrestamo] [int] NOT NULL,
	[MontoPrestamo] [decimal](18, 2) NULL,
	[Cuotas] [decimal](18, 2) NULL,
	[CantidadCuotas] [int] NOT NULL,
	[FechaCreacion] [date] NOT NULL,
	[FechaInicioPago] [date] NOT NULL,
	[Autorizado] [bit] NULL,
	[IDUsuarioAutorizo] [int] NULL,
	[FechaHoraAutorizacion] [datetime] NULL,
	[Cancelado] [bit] NULL,
	[IDUsuarioCancelo] [int] NULL,
	[FechaHoraCancelacion] [datetime] NULL,
	[MotivoCancelacion] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[IDPrestamo] [int] NULL,
	[Descripcion] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[Intereses] [decimal](18, 2) NULL,
	[IDEstatusSolicitudPrestamo] [int] NOT NULL,
	[IDFondoAhorro] [int] NULL,
	[IDEstatusPrestamo] [int] NULL,
 CONSTRAINT [PK_IntranetTblSolicitudesPrestamos_IDSolicitudPrestamo] PRIMARY KEY CLUSTERED 
(
	[IDSolicitudPrestamo] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IDX_IntranetTblSolicitudesPrestamos_IDEmpleado] ON [Intranet].[tblSolicitudesPrestamos]
(
	[IDEmpleado] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IDX_IntranetTblSolicitudesPrestamos_IDTipoPrestamo] ON [Intranet].[tblSolicitudesPrestamos]
(
	[IDTipoPrestamo] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
ALTER TABLE [Intranet].[tblSolicitudesPrestamos] ADD  CONSTRAINT [DF_IntranetTblSolicitudesPrestamos_FechaCreacion]  DEFAULT (getdate()) FOR [FechaCreacion]
GO
ALTER TABLE [Intranet].[tblSolicitudesPrestamos] ADD  CONSTRAINT [D_IntranetTblSolicitudesPrestamos_Interes]  DEFAULT ((0)) FOR [Intereses]
GO
ALTER TABLE [Intranet].[tblSolicitudesPrestamos]  WITH CHECK ADD  CONSTRAINT [Fk_IntranetTblCatEstatusSolicitudesPrestamos_IntranetTblSolicitudesPrestamos_IDEstatusSolicitudPrestamo] FOREIGN KEY([IDEstatusSolicitudPrestamo])
REFERENCES [Intranet].[tblCatEstatusSolicitudesPrestamos] ([IDEstatusSolicitudPrestamo])
GO
ALTER TABLE [Intranet].[tblSolicitudesPrestamos] CHECK CONSTRAINT [Fk_IntranetTblCatEstatusSolicitudesPrestamos_IntranetTblSolicitudesPrestamos_IDEstatusSolicitudPrestamo]
GO
ALTER TABLE [Intranet].[tblSolicitudesPrestamos]  WITH CHECK ADD  CONSTRAINT [FK_IntranetTblSolicitudesPrestamos_IDTipoPrestamo] FOREIGN KEY([IDTipoPrestamo])
REFERENCES [Nomina].[tblCatTiposPrestamo] ([IDTipoPrestamo])
GO
ALTER TABLE [Intranet].[tblSolicitudesPrestamos] CHECK CONSTRAINT [FK_IntranetTblSolicitudesPrestamos_IDTipoPrestamo]
GO
ALTER TABLE [Intranet].[tblSolicitudesPrestamos]  WITH CHECK ADD  CONSTRAINT [Fk_IntranetTblSolicitudesPrestamos_NominaTblCatEstatusPrestamo_IDEstatusPrestamo] FOREIGN KEY([IDEstatusPrestamo])
REFERENCES [Nomina].[tblCatEstatusPrestamo] ([IDEstatusPrestamo])
GO
ALTER TABLE [Intranet].[tblSolicitudesPrestamos] CHECK CONSTRAINT [Fk_IntranetTblSolicitudesPrestamos_NominaTblCatEstatusPrestamo_IDEstatusPrestamo]
GO
ALTER TABLE [Intranet].[tblSolicitudesPrestamos]  WITH CHECK ADD  CONSTRAINT [Fk_IntranetTblSolicitudesPrestamos_NominaTblCatFondosAhorro_IDFondoAhorro] FOREIGN KEY([IDFondoAhorro])
REFERENCES [Nomina].[tblCatFondosAhorro] ([IDFondoAhorro])
GO
ALTER TABLE [Intranet].[tblSolicitudesPrestamos] CHECK CONSTRAINT [Fk_IntranetTblSolicitudesPrestamos_NominaTblCatFondosAhorro_IDFondoAhorro]
GO
ALTER TABLE [Intranet].[tblSolicitudesPrestamos]  WITH CHECK ADD  CONSTRAINT [Fk_NominaTblPrestamos_IntranetTblSolicitudesPrestamos_IDPrestamo] FOREIGN KEY([IDPrestamo])
REFERENCES [Nomina].[tblPrestamos] ([IDPrestamo])
GO
ALTER TABLE [Intranet].[tblSolicitudesPrestamos] CHECK CONSTRAINT [Fk_NominaTblPrestamos_IntranetTblSolicitudesPrestamos_IDPrestamo]
GO
ALTER TABLE [Intranet].[tblSolicitudesPrestamos]  WITH CHECK ADD  CONSTRAINT [FK_RHtblEmpleados_IntranetTblSolicitudesPrestamos_IDEmpleado] FOREIGN KEY([IDEmpleado])
REFERENCES [RH].[tblEmpleados] ([IDEmpleado])
GO
ALTER TABLE [Intranet].[tblSolicitudesPrestamos] CHECK CONSTRAINT [FK_RHtblEmpleados_IntranetTblSolicitudesPrestamos_IDEmpleado]
GO
ALTER TABLE [Intranet].[tblSolicitudesPrestamos]  WITH CHECK ADD  CONSTRAINT [Fk_SeguridadTblUsuarios_IntranetTblSolicitudesPrestamos_IDUsuarioAutorizo] FOREIGN KEY([IDUsuarioAutorizo])
REFERENCES [Seguridad].[tblUsuarios] ([IDUsuario])
GO
ALTER TABLE [Intranet].[tblSolicitudesPrestamos] CHECK CONSTRAINT [Fk_SeguridadTblUsuarios_IntranetTblSolicitudesPrestamos_IDUsuarioAutorizo]
GO
ALTER TABLE [Intranet].[tblSolicitudesPrestamos]  WITH CHECK ADD  CONSTRAINT [Fk_SeguridadTblUsuarios_IntranetTblSolicitudesPrestamos_IDUsuarioCancelo] FOREIGN KEY([IDUsuarioCancelo])
REFERENCES [Seguridad].[tblUsuarios] ([IDUsuario])
GO
ALTER TABLE [Intranet].[tblSolicitudesPrestamos] CHECK CONSTRAINT [Fk_SeguridadTblUsuarios_IntranetTblSolicitudesPrestamos_IDUsuarioCancelo]
GO
