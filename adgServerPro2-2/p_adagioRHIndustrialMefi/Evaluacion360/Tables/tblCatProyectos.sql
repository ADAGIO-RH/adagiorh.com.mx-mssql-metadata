USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Evaluacion360].[tblCatProyectos](
	[IDProyecto] [int] IDENTITY(1,1) NOT NULL,
	[Nombre] [App].[MDName] NOT NULL,
	[Descripcion] [App].[MDDescription] NULL,
	[FechaCreacion] [datetime] NULL,
	[IDUsuario] [int] NOT NULL,
	[TotalPruebasARealizar] [int] NULL,
	[TotalPruebasRealizadas] [int] NULL,
	[Progreso] [int] NULL,
	[FechaInicio] [date] NULL,
	[FechaFin] [date] NULL,
	[Calendarizado] [bit] NULL,
	[IDTask] [int] NULL,
	[IDSchedule] [int] NULL,
	[Introduccion] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[Indicacion] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[IDTipoProyecto] [int] NULL,
	[Privacidad] [bit] NOT NULL,
 CONSTRAINT [Pk_Evaluacion360TblCatProyectos_IDProyecto] PRIMARY KEY CLUSTERED 
(
	[IDProyecto] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [Evaluacion360].[tblCatProyectos] ADD  CONSTRAINT [D_Evaluacion360TblCatProyectos_FechaCreacion]  DEFAULT (getdate()) FOR [FechaCreacion]
GO
ALTER TABLE [Evaluacion360].[tblCatProyectos] ADD  DEFAULT ((0)) FOR [TotalPruebasARealizar]
GO
ALTER TABLE [Evaluacion360].[tblCatProyectos] ADD  DEFAULT ((0)) FOR [TotalPruebasRealizadas]
GO
ALTER TABLE [Evaluacion360].[tblCatProyectos] ADD  DEFAULT ((0)) FOR [Progreso]
GO
ALTER TABLE [Evaluacion360].[tblCatProyectos] ADD  CONSTRAINT [D_Evaluacion360TblCatProyectos_Calendarizado]  DEFAULT ((0)) FOR [Calendarizado]
GO
ALTER TABLE [Evaluacion360].[tblCatProyectos] ADD  DEFAULT ((0)) FOR [Privacidad]
GO
ALTER TABLE [Evaluacion360].[tblCatProyectos]  WITH CHECK ADD  CONSTRAINT [Fk_Evaluacion360TblCatProyectos_Evaluacion360TblCatTiposProyectos_IDTipoProyecto] FOREIGN KEY([IDTipoProyecto])
REFERENCES [Evaluacion360].[tblCatTiposProyectos] ([IDTipoProyecto])
GO
ALTER TABLE [Evaluacion360].[tblCatProyectos] CHECK CONSTRAINT [Fk_Evaluacion360TblCatProyectos_Evaluacion360TblCatTiposProyectos_IDTipoProyecto]
GO
ALTER TABLE [Evaluacion360].[tblCatProyectos]  WITH CHECK ADD  CONSTRAINT [Fk_Evaluacion360TblCatProyectos_IDSchedule] FOREIGN KEY([IDSchedule])
REFERENCES [Scheduler].[tblSchedule] ([IDSchedule])
GO
ALTER TABLE [Evaluacion360].[tblCatProyectos] CHECK CONSTRAINT [Fk_Evaluacion360TblCatProyectos_IDSchedule]
GO
ALTER TABLE [Evaluacion360].[tblCatProyectos]  WITH CHECK ADD  CONSTRAINT [Fk_Evaluacion360TblCatProyectos_IDTask] FOREIGN KEY([IDTask])
REFERENCES [Scheduler].[tblTask] ([IDTask])
GO
ALTER TABLE [Evaluacion360].[tblCatProyectos] CHECK CONSTRAINT [Fk_Evaluacion360TblCatProyectos_IDTask]
GO
ALTER TABLE [Evaluacion360].[tblCatProyectos]  WITH CHECK ADD  CONSTRAINT [Fk_Evaluacion360TblCatProyectos_SeguridadTblUsuarios_IDUsuario] FOREIGN KEY([IDUsuario])
REFERENCES [Seguridad].[tblUsuarios] ([IDUsuario])
GO
ALTER TABLE [Evaluacion360].[tblCatProyectos] CHECK CONSTRAINT [Fk_Evaluacion360TblCatProyectos_SeguridadTblUsuarios_IDUsuario]
GO
