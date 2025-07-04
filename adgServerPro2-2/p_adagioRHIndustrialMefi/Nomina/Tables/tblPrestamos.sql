USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Nomina].[tblPrestamos](
	[IDPrestamo] [int] IDENTITY(1,1) NOT NULL,
	[Codigo] [varchar](20) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[IDEmpleado] [int] NOT NULL,
	[IDTipoPrestamo] [int] NOT NULL,
	[IDEstatusPrestamo] [int] NULL,
	[MontoPrestamo] [decimal](18, 2) NULL,
	[Cuotas] [decimal](18, 2) NULL,
	[CantidadCuotas] [int] NOT NULL,
	[Descripcion] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NOT NULL,
	[FechaCreacion] [date] NOT NULL,
	[FechaInicioPago] [date] NOT NULL,
	[Intereses] [decimal](18, 2) NULL,
 CONSTRAINT [PK_NominatblPrestamos_IDPrestamo] PRIMARY KEY CLUSTERED 
(
	[IDPrestamo] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
 CONSTRAINT [U_NominatblPrestamos_Codigo] UNIQUE NONCLUSTERED 
(
	[Codigo] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_NominatblPrestamos_IDEmpleado] ON [Nomina].[tblPrestamos]
(
	[IDEmpleado] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_NominatblPrestamos_IDEstatusPrestamo] ON [Nomina].[tblPrestamos]
(
	[IDEstatusPrestamo] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_NominatblPrestamos_IDTipoPrestamo] ON [Nomina].[tblPrestamos]
(
	[IDTipoPrestamo] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
ALTER TABLE [Nomina].[tblPrestamos] ADD  CONSTRAINT [DF_NominatblPrestamo_FechaCreacion]  DEFAULT (getdate()) FOR [FechaCreacion]
GO
ALTER TABLE [Nomina].[tblPrestamos] ADD  DEFAULT ((0)) FOR [Intereses]
GO
ALTER TABLE [Nomina].[tblPrestamos]  WITH CHECK ADD  CONSTRAINT [FK_NominatblCatEstatusPrestamo_NominatblPrestamo_IDEstatusPrestamo] FOREIGN KEY([IDEstatusPrestamo])
REFERENCES [Nomina].[tblCatEstatusPrestamo] ([IDEstatusPrestamo])
GO
ALTER TABLE [Nomina].[tblPrestamos] CHECK CONSTRAINT [FK_NominatblCatEstatusPrestamo_NominatblPrestamo_IDEstatusPrestamo]
GO
ALTER TABLE [Nomina].[tblPrestamos]  WITH CHECK ADD  CONSTRAINT [FK_NominaTblCatTiposPrestamo_IDTipoPrestamo] FOREIGN KEY([IDTipoPrestamo])
REFERENCES [Nomina].[tblCatTiposPrestamo] ([IDTipoPrestamo])
GO
ALTER TABLE [Nomina].[tblPrestamos] CHECK CONSTRAINT [FK_NominaTblCatTiposPrestamo_IDTipoPrestamo]
GO
ALTER TABLE [Nomina].[tblPrestamos]  WITH CHECK ADD  CONSTRAINT [FK_RHtblEmpleados_NominatblPrestamos_IDEmpleado] FOREIGN KEY([IDEmpleado])
REFERENCES [RH].[tblEmpleados] ([IDEmpleado])
GO
ALTER TABLE [Nomina].[tblPrestamos] CHECK CONSTRAINT [FK_RHtblEmpleados_NominatblPrestamos_IDEmpleado]
GO
