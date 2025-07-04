USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Comedor].[tblHistorialDisponibilidadMenu](
	[IDHistorialDisponibilidadMenu] [int] IDENTITY(1,1) NOT NULL,
	[IDMenu] [int] NOT NULL,
	[FechaInicio] [date] NOT NULL,
	[FechaFin] [date] NOT NULL,
	[HoraInicio] [time](7) NULL,
	[HoraFin] [time](7) NULL,
	[OpcionesArticulosDisponbibles] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[Activo] [bit] NOT NULL,
 CONSTRAINT [Pk_ComedorTblHistorialDisponibilidadMenu_IDHistorialDisponibilidadMenu] PRIMARY KEY CLUSTERED 
(
	[IDHistorialDisponibilidadMenu] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [Comedor].[tblHistorialDisponibilidadMenu] ADD  CONSTRAINT [D_ComedorTblHistorialDisponibilidadMenu_Activo]  DEFAULT ((0)) FOR [Activo]
GO
ALTER TABLE [Comedor].[tblHistorialDisponibilidadMenu]  WITH CHECK ADD  CONSTRAINT [Fk_ComedorTblHistorialDisponibilidadMenu_ComedorTblCatMenus_IDMenu] FOREIGN KEY([IDMenu])
REFERENCES [Comedor].[tblCatMenus] ([IDMenu])
ON DELETE CASCADE
GO
ALTER TABLE [Comedor].[tblHistorialDisponibilidadMenu] CHECK CONSTRAINT [Fk_ComedorTblHistorialDisponibilidadMenu_ComedorTblCatMenus_IDMenu]
GO
