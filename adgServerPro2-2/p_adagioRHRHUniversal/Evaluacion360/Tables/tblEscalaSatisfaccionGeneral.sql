USE [p_adagioRHRHUniversal]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Evaluacion360].[tblEscalaSatisfaccionGeneral](
	[IDEscalaSatisfaccion] [int] IDENTITY(1,1) NOT NULL,
	[Nombre] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[Descripcion] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[Min] [float] NULL,
	[Max] [float] NULL,
	[Color] [varchar](20) COLLATE SQL_Latin1_General_CP1_CI_AI NOT NULL,
	[IndiceSatisfaccion] [int] NOT NULL,
	[IDProyecto] [int] NOT NULL,
 CONSTRAINT [Pk_Evaluacion360tblEscalaSatisfaccionGeneral_IDEscalaSatisfaccion] PRIMARY KEY CLUSTERED 
(
	[IDEscalaSatisfaccion] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
 CONSTRAINT [U_Evaluacion360TblEscalaSatisfaccionGeneral_IndiceSatisfaccion_IDProyecto] UNIQUE NONCLUSTERED 
(
	[IndiceSatisfaccion] ASC,
	[IDProyecto] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Evaluacion360].[tblEscalaSatisfaccionGeneral]  WITH CHECK ADD  CONSTRAINT [FK_Evaluacion360tblEscalaSatisfaccionGeneral_Evaluacion360tblCatProyectos_IDProyecto] FOREIGN KEY([IDProyecto])
REFERENCES [Evaluacion360].[tblCatProyectos] ([IDProyecto])
GO
ALTER TABLE [Evaluacion360].[tblEscalaSatisfaccionGeneral] CHECK CONSTRAINT [FK_Evaluacion360tblEscalaSatisfaccionGeneral_Evaluacion360tblCatProyectos_IDProyecto]
GO
