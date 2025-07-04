USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [RH].[tblCatTipoContactoEmpleado](
	[IDTipoContacto] [int] IDENTITY(1,1) NOT NULL,
	[Descripcion] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[Mask] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[CssClassIcon] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[IDMedioNotificacion] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[Traduccion] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
 CONSTRAINT [PK_tblCatTipoContactoEmpleado_IDTipoContacto] PRIMARY KEY CLUSTERED 
(
	[IDTipoContacto] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [RH].[tblCatTipoContactoEmpleado]  WITH CHECK ADD  CONSTRAINT [FK_AppTblMediosNotificaciones_RHTblCatTiposContactoEmpleado_IDMedioNotificacion] FOREIGN KEY([IDMedioNotificacion])
REFERENCES [App].[tblMediosNotificaciones] ([IDMedioNotificacion])
GO
ALTER TABLE [RH].[tblCatTipoContactoEmpleado] CHECK CONSTRAINT [FK_AppTblMediosNotificaciones_RHTblCatTiposContactoEmpleado_IDMedioNotificacion]
GO
