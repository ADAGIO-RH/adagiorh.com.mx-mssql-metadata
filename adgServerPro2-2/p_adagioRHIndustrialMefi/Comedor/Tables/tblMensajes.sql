USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Comedor].[tblMensajes](
	[IDMensaje] [int] IDENTITY(1,1) NOT NULL,
	[Mensaje] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NOT NULL,
	[FechaIni] [date] NOT NULL,
	[FechaFin] [date] NOT NULL,
	[IDUsuario] [int] NOT NULL,
	[FechaHoraCreacion] [datetime] NULL,
	[TipoMensaje] [varchar](10) COLLATE SQL_Latin1_General_CP1_CI_AI NOT NULL,
	[IdsRestaurantes] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
 CONSTRAINT [Pk_ComedorTblMensajes_IDMensaje] PRIMARY KEY CLUSTERED 
(
	[IDMensaje] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [Comedor].[tblMensajes] ADD  CONSTRAINT [D_ComedorTblMensajes_FechaHoraCreacion]  DEFAULT (getdate()) FOR [FechaHoraCreacion]
GO
ALTER TABLE [Comedor].[tblMensajes]  WITH CHECK ADD  CONSTRAINT [Fk_ComedorTblMensajes_SeguridadTblUsuarios_IDUsuario] FOREIGN KEY([IDUsuario])
REFERENCES [Seguridad].[tblUsuarios] ([IDUsuario])
GO
ALTER TABLE [Comedor].[tblMensajes] CHECK CONSTRAINT [Fk_ComedorTblMensajes_SeguridadTblUsuarios_IDUsuario]
GO
