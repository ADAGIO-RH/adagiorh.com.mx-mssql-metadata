USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [RH].[tblEstatusPlazas](
	[IDEstatusPlaza] [int] IDENTITY(1,1) NOT NULL,
	[IDPlaza] [int] NOT NULL,
	[IDEstatus] [int] NOT NULL,
	[IDUsuario] [int] NULL,
	[FechaReg] [datetime] NOT NULL,
 CONSTRAINT [Pk_RHTblEstatusPlazas_IDEstatusPlaza] PRIMARY KEY CLUSTERED 
(
	[IDEstatusPlaza] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [RH].[tblEstatusPlazas] ADD  CONSTRAINT [D_RHTblEstatusPlazas_FechaReg]  DEFAULT (getdate()) FOR [FechaReg]
GO
ALTER TABLE [RH].[tblEstatusPlazas]  WITH CHECK ADD  CONSTRAINT [Fk_RHTblEstatusPlazas_RHTblCatPlazas_IDPlaza] FOREIGN KEY([IDPlaza])
REFERENCES [RH].[tblCatPlazas] ([IDPlaza])
ON DELETE CASCADE
GO
ALTER TABLE [RH].[tblEstatusPlazas] CHECK CONSTRAINT [Fk_RHTblEstatusPlazas_RHTblCatPlazas_IDPlaza]
GO
ALTER TABLE [RH].[tblEstatusPlazas]  WITH CHECK ADD  CONSTRAINT [Fk_RHTblEstatusPlazas_SeguridadTblUsuarios_IDUsuario] FOREIGN KEY([IDUsuario])
REFERENCES [Seguridad].[tblUsuarios] ([IDUsuario])
GO
ALTER TABLE [RH].[tblEstatusPlazas] CHECK CONSTRAINT [Fk_RHTblEstatusPlazas_SeguridadTblUsuarios_IDUsuario]
GO
