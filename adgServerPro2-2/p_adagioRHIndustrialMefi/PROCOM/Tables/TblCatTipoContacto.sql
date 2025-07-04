USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [PROCOM].[TblCatTipoContacto](
	[IDCatTipoContacto] [int] IDENTITY(1,1) NOT NULL,
	[IDMedioNotificacion] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AI NOT NULL,
	[Descripcion] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
 CONSTRAINT [PK_ProcomTblCatTipoContacto_IDCatTipoContacto] PRIMARY KEY CLUSTERED 
(
	[IDCatTipoContacto] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [PROCOM].[TblCatTipoContacto]  WITH CHECK ADD  CONSTRAINT [FK_AppTblMediosNotificaciones_ProcomTblCatTipoContacto_IDMedioNotificacion] FOREIGN KEY([IDMedioNotificacion])
REFERENCES [App].[tblMediosNotificaciones] ([IDMedioNotificacion])
GO
ALTER TABLE [PROCOM].[TblCatTipoContacto] CHECK CONSTRAINT [FK_AppTblMediosNotificaciones_ProcomTblCatTipoContacto_IDMedioNotificacion]
GO
