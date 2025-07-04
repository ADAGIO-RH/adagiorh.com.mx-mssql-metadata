USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Enrutamiento].[tblUnidadProceso](
	[IDUnidad] [int] IDENTITY(1,1) NOT NULL,
	[IDCatTipoProceso] [int] NOT NULL,
	[Codigo] [varchar](20) COLLATE SQL_Latin1_General_CP1_CI_AI NOT NULL,
	[Descripcion] [varchar](500) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[IDUsuarioCreador] [int] NOT NULL,
	[FechaHoraCreacion] [datetime] NULL,
	[IDReferencia] [int] NOT NULL,
	[IDEstatus] [int] NOT NULL,
	[IDCliente] [int] NOT NULL,
 CONSTRAINT [PK_EnrutamientoTblUnidadProceso_IDUnidad] PRIMARY KEY CLUSTERED 
(
	[IDUnidad] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Enrutamiento].[tblUnidadProceso]  WITH CHECK ADD  CONSTRAINT [FK_RHTblCatClientes_EnrutamientoTblUnidadProceso_IDCliente] FOREIGN KEY([IDCliente])
REFERENCES [RH].[tblCatClientes] ([IDCliente])
GO
ALTER TABLE [Enrutamiento].[tblUnidadProceso] CHECK CONSTRAINT [FK_RHTblCatClientes_EnrutamientoTblUnidadProceso_IDCliente]
GO
ALTER TABLE [Enrutamiento].[tblUnidadProceso]  WITH CHECK ADD  CONSTRAINT [FK_SeguridadTblUsuarios_EnrutamientoTblUnidadProceso_IDUsuarioCreador] FOREIGN KEY([IDUsuarioCreador])
REFERENCES [Seguridad].[tblUsuarios] ([IDUsuario])
GO
ALTER TABLE [Enrutamiento].[tblUnidadProceso] CHECK CONSTRAINT [FK_SeguridadTblUsuarios_EnrutamientoTblUnidadProceso_IDUsuarioCreador]
GO
