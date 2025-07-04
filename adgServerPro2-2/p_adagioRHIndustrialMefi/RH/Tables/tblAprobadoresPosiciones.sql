USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [RH].[tblAprobadoresPosiciones](
	[IDAprobadorPosicion] [int] IDENTITY(1,1) NOT NULL,
	[IDPosicion] [int] NOT NULL,
	[IDUsuario] [int] NOT NULL,
	[Aprobacion] [int] NOT NULL,
	[Observacion] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[FechaAprobacion] [datetime] NULL,
	[Secuencia] [int] NOT NULL,
	[Orden] [int] NULL,
 CONSTRAINT [Pk_RHTblAprobadoresPosiciones_IDAprobadorPosicion] PRIMARY KEY CLUSTERED 
(
	[IDAprobadorPosicion] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [RH].[tblAprobadoresPosiciones] ADD  CONSTRAINT [Pk_RHTblAprobadoresPosiciones_Aprobacion]  DEFAULT ((0)) FOR [Aprobacion]
GO
ALTER TABLE [RH].[tblAprobadoresPosiciones]  WITH CHECK ADD  CONSTRAINT [Fk_RHTblAprobadoresPosiciones_RHTblCatPosiciones_IDPosicion] FOREIGN KEY([IDPosicion])
REFERENCES [RH].[tblCatPosiciones] ([IDPosicion])
ON DELETE CASCADE
GO
ALTER TABLE [RH].[tblAprobadoresPosiciones] CHECK CONSTRAINT [Fk_RHTblAprobadoresPosiciones_RHTblCatPosiciones_IDPosicion]
GO
ALTER TABLE [RH].[tblAprobadoresPosiciones]  WITH CHECK ADD  CONSTRAINT [Fk_RHTblAprobadoresPosiciones_SeguridadTblUsuarios_IDUsuario] FOREIGN KEY([IDUsuario])
REFERENCES [Seguridad].[tblUsuarios] ([IDUsuario])
ON DELETE CASCADE
GO
ALTER TABLE [RH].[tblAprobadoresPosiciones] CHECK CONSTRAINT [Fk_RHTblAprobadoresPosiciones_SeguridadTblUsuarios_IDUsuario]
GO
