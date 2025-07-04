USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Evaluacion360].[tblCatCiclosMedicionObjetivos](
	[IDCicloMedicionObjetivo] [int] IDENTITY(1,1) NOT NULL,
	[Nombre] [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AI NOT NULL,
	[FechaInicio] [date] NOT NULL,
	[FechaFin] [date] NOT NULL,
	[IDEstatusCicloMedicion] [int] NOT NULL,
	[IDUsuario] [int] NOT NULL,
	[FechaHoraReg] [datetime] NOT NULL,
	[FechaParaActualizacionEstatusObjetivos] [datetime] NULL,
	[PermitirIngresoObjetivosEmpleados] [bit] NOT NULL,
	[EmpleadoApruebaObjetivos] [bit] NOT NULL,
 CONSTRAINT [Pk_Evaluacion360TblCatCiclosMedicionObjetivos_IDCicloMedicionObjetivo] PRIMARY KEY CLUSTERED 
(
	[IDCicloMedicionObjetivo] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
 CONSTRAINT [U_Evaluacion360TblCatCiclosMedicionObjetivos_Nombre] UNIQUE NONCLUSTERED 
(
	[Nombre] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Evaluacion360].[tblCatCiclosMedicionObjetivos] ADD  CONSTRAINT [D_Evaluacion360TblCiclosMedicionObjetivos_FechaHoraReg]  DEFAULT (getdate()) FOR [FechaHoraReg]
GO
ALTER TABLE [Evaluacion360].[tblCatCiclosMedicionObjetivos]  WITH CHECK ADD  CONSTRAINT [Fk_Evaluacion360TblCatCiclosMedicionObjetivos_Evaluacion360TblCatEstatusCiclosMedicion_IDEstatusCicloMedicion] FOREIGN KEY([IDEstatusCicloMedicion])
REFERENCES [Evaluacion360].[tblCatEstatusCiclosMedicion] ([IDEstatusCicloMedicion])
GO
ALTER TABLE [Evaluacion360].[tblCatCiclosMedicionObjetivos] CHECK CONSTRAINT [Fk_Evaluacion360TblCatCiclosMedicionObjetivos_Evaluacion360TblCatEstatusCiclosMedicion_IDEstatusCicloMedicion]
GO
ALTER TABLE [Evaluacion360].[tblCatCiclosMedicionObjetivos]  WITH CHECK ADD  CONSTRAINT [FkEvaluacion360TblCiclosMedicionObjetivos_SeguridadTblUsuarios_IDUsuario] FOREIGN KEY([IDUsuario])
REFERENCES [Seguridad].[tblUsuarios] ([IDUsuario])
ON DELETE CASCADE
GO
ALTER TABLE [Evaluacion360].[tblCatCiclosMedicionObjetivos] CHECK CONSTRAINT [FkEvaluacion360TblCiclosMedicionObjetivos_SeguridadTblUsuarios_IDUsuario]
GO
