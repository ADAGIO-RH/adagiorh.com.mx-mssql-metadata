USE [p_adagioRHHPM]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Evaluacion360].[tblAdministradoresProyecto](
	[IDAdministradorProyecto] [int] IDENTITY(1,1) NOT NULL,
	[IDProyecto] [int] NOT NULL,
	[IDUsuario] [int] NOT NULL,
 CONSTRAINT [Pk_Evaluacion360TblAdministradoresProyecto_IDAdministradorProyecto] PRIMARY KEY CLUSTERED 
(
	[IDAdministradorProyecto] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
