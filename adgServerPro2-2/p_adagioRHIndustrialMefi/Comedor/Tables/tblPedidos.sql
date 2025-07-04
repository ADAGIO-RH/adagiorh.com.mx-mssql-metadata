USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Comedor].[tblPedidos](
	[IDPedido] [int] IDENTITY(1,1) NOT NULL,
	[Numero] [int] NOT NULL,
	[IDRestaurante] [int] NOT NULL,
	[IDEmpleado] [int] NOT NULL,
	[IDEmpleadoRecibe] [int] NULL,
	[Autorizado] [bit] NOT NULL,
	[IDEmpleadoAutorizo] [int] NULL,
	[IDUsuarioAutorizo] [int] NULL,
	[FechaHoraAutorizacion] [datetime] NULL,
	[ComandaImpresa] [bit] NOT NULL,
	[FechaHoraImpresion] [datetime] NULL,
	[DescontadaDeNomina] [bit] NOT NULL,
	[FechaHoraDescuento] [datetime] NULL,
	[IDPeriodo] [int] NULL,
	[Cancelada] [bit] NOT NULL,
	[NotaCancelacion] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[FechaCancelacion] [datetime] NULL,
	[FechaCreacion] [date] NOT NULL,
	[HoraCreacion] [time](7) NOT NULL,
	[GrandTotal] [money] NULL,
	[NotaAutorizacion] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[IDUsuarioCancelo] [int] NULL,
 CONSTRAINT [Pk_ComedorTblPedidos_IDPedido] PRIMARY KEY CLUSTERED 
(
	[IDPedido] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
 CONSTRAINT [U_ComedorTblPedidos_NumeroIDRestauranteFechaCreacion] UNIQUE NONCLUSTERED 
(
	[Numero] ASC,
	[IDRestaurante] ASC,
	[FechaCreacion] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [Comedor].[tblPedidos] ADD  CONSTRAINT [D_ComedorTblPedidos_Autorizado]  DEFAULT ((0)) FOR [Autorizado]
GO
ALTER TABLE [Comedor].[tblPedidos] ADD  CONSTRAINT [D_ComedorTblPedidos_ComandoImpresa]  DEFAULT ((0)) FOR [ComandaImpresa]
GO
ALTER TABLE [Comedor].[tblPedidos] ADD  CONSTRAINT [D_ComedorTblPedidos_DescantadaDeNomina]  DEFAULT ((0)) FOR [DescontadaDeNomina]
GO
ALTER TABLE [Comedor].[tblPedidos] ADD  CONSTRAINT [D_ComedorTblPedidos_Cancelada]  DEFAULT ((0)) FOR [Cancelada]
GO
ALTER TABLE [Comedor].[tblPedidos] ADD  CONSTRAINT [D_ComedorTblPedidos_FechaCreacion]  DEFAULT (getdate()) FOR [FechaCreacion]
GO
ALTER TABLE [Comedor].[tblPedidos] ADD  CONSTRAINT [D_ComedorTblPedidos_HoraCreacion]  DEFAULT (getdate()) FOR [HoraCreacion]
GO
ALTER TABLE [Comedor].[tblPedidos] ADD  CONSTRAINT [D_ComedorTblPedidos_GrandTotal]  DEFAULT ((0)) FOR [GrandTotal]
GO
ALTER TABLE [Comedor].[tblPedidos]  WITH CHECK ADD  CONSTRAINT [Fk_ComedorTblPedidos_NominaTblCatPeriodos] FOREIGN KEY([IDPeriodo])
REFERENCES [Nomina].[tblCatPeriodos] ([IDPeriodo])
GO
ALTER TABLE [Comedor].[tblPedidos] CHECK CONSTRAINT [Fk_ComedorTblPedidos_NominaTblCatPeriodos]
GO
ALTER TABLE [Comedor].[tblPedidos]  WITH CHECK ADD  CONSTRAINT [Fk_ComedorTblPedidos_RHTblEmpleados_IDEmpleado] FOREIGN KEY([IDEmpleado])
REFERENCES [RH].[tblEmpleados] ([IDEmpleado])
GO
ALTER TABLE [Comedor].[tblPedidos] CHECK CONSTRAINT [Fk_ComedorTblPedidos_RHTblEmpleados_IDEmpleado]
GO
ALTER TABLE [Comedor].[tblPedidos]  WITH CHECK ADD  CONSTRAINT [Fk_ComedorTblPedidos_RHTblEmpleados_IDEmpleadoAutorizo] FOREIGN KEY([IDEmpleadoAutorizo])
REFERENCES [RH].[tblEmpleados] ([IDEmpleado])
GO
ALTER TABLE [Comedor].[tblPedidos] CHECK CONSTRAINT [Fk_ComedorTblPedidos_RHTblEmpleados_IDEmpleadoAutorizo]
GO
ALTER TABLE [Comedor].[tblPedidos]  WITH CHECK ADD  CONSTRAINT [Fk_ComedorTblPedidos_RHTblEmpleados_IDEmpleadoRecibe] FOREIGN KEY([IDEmpleadoRecibe])
REFERENCES [RH].[tblEmpleados] ([IDEmpleado])
GO
ALTER TABLE [Comedor].[tblPedidos] CHECK CONSTRAINT [Fk_ComedorTblPedidos_RHTblEmpleados_IDEmpleadoRecibe]
GO
ALTER TABLE [Comedor].[tblPedidos]  WITH CHECK ADD  CONSTRAINT [Fk_ComedorTblPedidos_SeguridaUsuarios_IDUsuarioAutorizo] FOREIGN KEY([IDUsuarioAutorizo])
REFERENCES [Seguridad].[tblUsuarios] ([IDUsuario])
GO
ALTER TABLE [Comedor].[tblPedidos] CHECK CONSTRAINT [Fk_ComedorTblPedidos_SeguridaUsuarios_IDUsuarioAutorizo]
GO
ALTER TABLE [Comedor].[tblPedidos]  WITH CHECK ADD  CONSTRAINT [Fk_ComedorTblPeriodos_ComedorTblCatRestaurantes_IDRestaurante] FOREIGN KEY([IDRestaurante])
REFERENCES [Comedor].[tblCatRestaurantes] ([IDRestaurante])
GO
ALTER TABLE [Comedor].[tblPedidos] CHECK CONSTRAINT [Fk_ComedorTblPeriodos_ComedorTblCatRestaurantes_IDRestaurante]
GO
ALTER TABLE [Comedor].[tblPedidos]  WITH CHECK ADD  CONSTRAINT [Pk_ComedorTblPedidos_SeguridadTblUsuarios_IDUsuarioCancelo] FOREIGN KEY([IDUsuarioCancelo])
REFERENCES [Seguridad].[tblUsuarios] ([IDUsuario])
GO
ALTER TABLE [Comedor].[tblPedidos] CHECK CONSTRAINT [Pk_ComedorTblPedidos_SeguridadTblUsuarios_IDUsuarioCancelo]
GO
