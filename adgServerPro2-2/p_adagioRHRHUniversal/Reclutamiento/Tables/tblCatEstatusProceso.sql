USE [p_adagioRHRHUniversal]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Reclutamiento].[tblCatEstatusProceso](
	[IDEstatusProceso] [int] IDENTITY(1,1) NOT NULL,
	[Descripcion] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[MostrarEnProcesoSeleccion] [bit] NULL,
	[Orden] [int] NULL,
	[Color] [varchar](10) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[ProcesoFinal] [bit] NOT NULL,
	[IDPlantilla] [int] NULL,
 CONSTRAINT [PK_ReclutamientoTblCatEstatusProceso_IDEstatusProceso] PRIMARY KEY CLUSTERED 
(
	[IDEstatusProceso] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
 CONSTRAINT [U_ReclutamientoTblCatEstatusProceso_Descripcion] UNIQUE NONCLUSTERED 
(
	[Descripcion] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Reclutamiento].[tblCatEstatusProceso] ADD  CONSTRAINT [D_ReclutamientoTblCatEstatusProceso_MostrarEnProcesoSeleccion]  DEFAULT ((1)) FOR [MostrarEnProcesoSeleccion]
GO
ALTER TABLE [Reclutamiento].[tblCatEstatusProceso] ADD  CONSTRAINT [D_ReclutamientoTblCatEstatusProceso_Color]  DEFAULT ('#047bf8') FOR [Color]
GO
ALTER TABLE [Reclutamiento].[tblCatEstatusProceso] ADD  CONSTRAINT [D_ReclutamientoTblCatEstatusProceso_ProcesoFinal]  DEFAULT ((0)) FOR [ProcesoFinal]
GO
ALTER TABLE [Reclutamiento].[tblCatEstatusProceso]  WITH CHECK ADD  CONSTRAINT [FK_tblCatEstatusProceso_tblPlantillas] FOREIGN KEY([IDPlantilla])
REFERENCES [Reclutamiento].[tblPlantillas] ([IDPlantilla])
GO
ALTER TABLE [Reclutamiento].[tblCatEstatusProceso] CHECK CONSTRAINT [FK_tblCatEstatusProceso_tblPlantillas]
GO
