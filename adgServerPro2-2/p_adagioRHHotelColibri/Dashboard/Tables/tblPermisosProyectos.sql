USE [p_adagioRHHotelColibri]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Dashboard].[tblPermisosProyectos](
	[IDProyecto] [int] NOT NULL,
	[IDUsuario] [int] NOT NULL,
	[Comentario] [bit] NULL,
 CONSTRAINT [Pk_DashboardTblPermisosProyectos_IDProyectoIDUsuario] PRIMARY KEY CLUSTERED 
(
	[IDProyecto] ASC,
	[IDUsuario] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
