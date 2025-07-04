USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [RH].[tblAprobadoresPredeterminadosPlazasPosiciones](
	[IDAprobadorPredeterminadoPlazaPosicion] [int] IDENTITY(1,1) NOT NULL,
	[IDCliente] [int] NOT NULL,
	[IDUsuario] [int] NOT NULL,
	[Orden] [int] NOT NULL,
	[FechaReg] [datetime] NULL,
 CONSTRAINT [Pk_RHTblAprobadoresPredeterminadosPlazasPosiciones_IDAprobadorPredeterminadoPlazaPosicion] PRIMARY KEY CLUSTERED 
(
	[IDAprobadorPredeterminadoPlazaPosicion] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
 CONSTRAINT [U_RHTblAprobadoresPredeterminadosPlazasPosiciones_IDClienteIDUsuario] UNIQUE NONCLUSTERED 
(
	[IDCliente] ASC,
	[IDUsuario] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [RH].[tblAprobadoresPredeterminadosPlazasPosiciones] ADD  CONSTRAINT [D_RHTblAprobadoresPredeterminadosPlazasPosiciones_Orden]  DEFAULT ((0)) FOR [Orden]
GO
ALTER TABLE [RH].[tblAprobadoresPredeterminadosPlazasPosiciones] ADD  CONSTRAINT [D_RHTblAprobadoresPredeterminadosPlazasPosiciones_FechaReg]  DEFAULT (getdate()) FOR [FechaReg]
GO
ALTER TABLE [RH].[tblAprobadoresPredeterminadosPlazasPosiciones]  WITH CHECK ADD  CONSTRAINT [Fk_RHTblAprobadoresPredeterminadosPlazasPosiciones_RHTblCatClientes_IDCliente] FOREIGN KEY([IDCliente])
REFERENCES [RH].[tblCatClientes] ([IDCliente])
ON DELETE CASCADE
GO
ALTER TABLE [RH].[tblAprobadoresPredeterminadosPlazasPosiciones] CHECK CONSTRAINT [Fk_RHTblAprobadoresPredeterminadosPlazasPosiciones_RHTblCatClientes_IDCliente]
GO
ALTER TABLE [RH].[tblAprobadoresPredeterminadosPlazasPosiciones]  WITH CHECK ADD  CONSTRAINT [Fk_RHTblAprobadoresPredeterminadosPlazasPosiciones_SeguridadTblUsuarios_IDUsuario] FOREIGN KEY([IDUsuario])
REFERENCES [Seguridad].[tblUsuarios] ([IDUsuario])
ON DELETE CASCADE
GO
ALTER TABLE [RH].[tblAprobadoresPredeterminadosPlazasPosiciones] CHECK CONSTRAINT [Fk_RHTblAprobadoresPredeterminadosPlazasPosiciones_SeguridadTblUsuarios_IDUsuario]
GO
