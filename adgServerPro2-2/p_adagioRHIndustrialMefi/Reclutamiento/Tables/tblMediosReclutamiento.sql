USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Reclutamiento].[tblMediosReclutamiento](
	[IDMedioReclutamiento] [int] IDENTITY(1,1) NOT NULL,
	[Nombre] [varchar](200) COLLATE SQL_Latin1_General_CP1_CI_AI NOT NULL,
	[IDTipoMedioReclutamiento] [int] NOT NULL,
	[Activo] [bit] NOT NULL,
 CONSTRAINT [Pk_ReclutamientoTblMediosReclutamiento_IDMedioReclutamiento] PRIMARY KEY CLUSTERED 
(
	[IDMedioReclutamiento] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
 CONSTRAINT [U_ReclutamientoTblMediosReclutamiento_Nombre_TipoMedioReclutamiento] UNIQUE NONCLUSTERED 
(
	[Nombre] ASC,
	[IDTipoMedioReclutamiento] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Reclutamiento].[tblMediosReclutamiento] ADD  CONSTRAINT [D_ReclutamientoTblMediosReclutamiento_Activo]  DEFAULT ((0)) FOR [Activo]
GO
