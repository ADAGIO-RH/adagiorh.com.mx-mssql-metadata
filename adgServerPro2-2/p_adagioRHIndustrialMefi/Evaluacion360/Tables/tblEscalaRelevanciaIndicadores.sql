USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Evaluacion360].[tblEscalaRelevanciaIndicadores](
	[IDEscalaRelevancia] [int] IDENTITY(1,1) NOT NULL,
	[Descripcion] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[Min] [float] NULL,
	[Max] [float] NULL,
	[IndiceRelevancia] [int] NOT NULL,
	[IDProyecto] [int] NOT NULL,
 CONSTRAINT [Pk_Evaluacion360tblEscalaRelevanciaIndicadores_IDEscalaRelevancia] PRIMARY KEY CLUSTERED 
(
	[IDEscalaRelevancia] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
 CONSTRAINT [U_Evaluacion360TblEscalaRelevanciaIndicadores_IndiceRelevancia_IDProyecto] UNIQUE NONCLUSTERED 
(
	[IndiceRelevancia] ASC,
	[IDProyecto] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Evaluacion360].[tblEscalaRelevanciaIndicadores]  WITH CHECK ADD  CONSTRAINT [FK_Evaluacion360tblEscalaRelevanciaIndicadores_Evaluacion360tblCatProyectos_IDProyecto] FOREIGN KEY([IDProyecto])
REFERENCES [Evaluacion360].[tblCatProyectos] ([IDProyecto])
GO
ALTER TABLE [Evaluacion360].[tblEscalaRelevanciaIndicadores] CHECK CONSTRAINT [FK_Evaluacion360tblEscalaRelevanciaIndicadores_Evaluacion360tblCatProyectos_IDProyecto]
GO
