USE [p_adagioRHElPro]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Evaluacion360].[tblCatObjetivos](
	[IDObjetivo] [int] IDENTITY(1,1) NOT NULL,
	[Nombre] [varchar](500) COLLATE SQL_Latin1_General_CP1_CI_AI NOT NULL,
	[Descripcion] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[IDCicloMedicionObjetivo] [int] NOT NULL,
	[IDTipoMedicionObjetivo] [int] NOT NULL,
	[IDEstatusObjetivo] [int] NOT NULL,
	[IDUsuario] [int] NOT NULL,
	[FechaHoraReg] [datetime] NOT NULL,
	[Progreso] [decimal](18, 2) NOT NULL,
 CONSTRAINT [Pk_Evaluacion360TblCatObjetivos_IDObjetivo] PRIMARY KEY CLUSTERED 
(
	[IDObjetivo] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [Evaluacion360].[tblCatObjetivos] ADD  CONSTRAINT [D_Evaluacion360TblCatObjetivos_FechaHoraReg]  DEFAULT (getdate()) FOR [FechaHoraReg]
GO
ALTER TABLE [Evaluacion360].[tblCatObjetivos] ADD  CONSTRAINT [D_Evaluacion360TblCatObjetivos_Progreso]  DEFAULT ((0)) FOR [Progreso]
GO
ALTER TABLE [Evaluacion360].[tblCatObjetivos]  WITH NOCHECK ADD  CONSTRAINT [Fk_Evaluacion360TblCatObjetivos_Evaluacion360TblCatCiclosMedicionObjetivos_IDCicloMedicionObjetivo] FOREIGN KEY([IDCicloMedicionObjetivo])
REFERENCES [Evaluacion360].[tblCatCiclosMedicionObjetivos] ([IDCicloMedicionObjetivo])
ON DELETE CASCADE
GO
ALTER TABLE [Evaluacion360].[tblCatObjetivos] CHECK CONSTRAINT [Fk_Evaluacion360TblCatObjetivos_Evaluacion360TblCatCiclosMedicionObjetivos_IDCicloMedicionObjetivo]
GO
ALTER TABLE [Evaluacion360].[tblCatObjetivos]  WITH NOCHECK ADD  CONSTRAINT [Fk_Evaluacion360TblCatObjetivos_Evaluacion360TblCatEstatusObjetivos_IDEstatusObjetivo] FOREIGN KEY([IDEstatusObjetivo])
REFERENCES [Evaluacion360].[tblCatEstatusObjetivos] ([IDEstatusObjetivo])
GO
ALTER TABLE [Evaluacion360].[tblCatObjetivos] CHECK CONSTRAINT [Fk_Evaluacion360TblCatObjetivos_Evaluacion360TblCatEstatusObjetivos_IDEstatusObjetivo]
GO
ALTER TABLE [Evaluacion360].[tblCatObjetivos]  WITH NOCHECK ADD  CONSTRAINT [Fk_Evaluacion360TblCatObjetivos_Evaluacion360TblCatTiposMedicionesObjetivos_IDTipoMedicionObjetivo] FOREIGN KEY([IDTipoMedicionObjetivo])
REFERENCES [Evaluacion360].[tblCatTiposMedicionesObjetivos] ([IDTipoMedicionObjetivo])
GO
ALTER TABLE [Evaluacion360].[tblCatObjetivos] CHECK CONSTRAINT [Fk_Evaluacion360TblCatObjetivos_Evaluacion360TblCatTiposMedicionesObjetivos_IDTipoMedicionObjetivo]
GO
