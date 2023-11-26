USE [p_adagioRHBelmondCSN]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Evaluacion360].[tblDetalleEscalaValoracion](
	[IDDetalleEscalaValoracion] [int] IDENTITY(1,1) NOT NULL,
	[IDEscalaValoracion] [int] NOT NULL,
	[Nombre] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AI NOT NULL,
	[Valor] [int] NOT NULL,
 CONSTRAINT [Pk_Evaluacion360TblDetalleEscalaValoracion_IDDetalleEscalaValoracion] PRIMARY KEY CLUSTERED 
(
	[IDDetalleEscalaValoracion] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 20, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
 CONSTRAINT [U_Evaluacion360TblDetalleEscalaValoracion_IDEscalaValoracionNombre] UNIQUE NONCLUSTERED 
(
	[IDEscalaValoracion] ASC,
	[Nombre] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 20, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
 CONSTRAINT [U_Evaluacion360TblDetalleEscalaValoracion_IDEscalaValoracionValor] UNIQUE NONCLUSTERED 
(
	[IDEscalaValoracion] ASC,
	[Valor] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 20, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Evaluacion360].[tblDetalleEscalaValoracion] ADD  CONSTRAINT [D_Evaluacion360TblDetalleEscalaValoracion_Valor]  DEFAULT ((0)) FOR [Valor]
GO
ALTER TABLE [Evaluacion360].[tblDetalleEscalaValoracion]  WITH CHECK ADD  CONSTRAINT [Fk_Evaluacion360TblDetalleEscalaValoracion_IDEscalaValoracion] FOREIGN KEY([IDEscalaValoracion])
REFERENCES [Evaluacion360].[tblCatEscalaValoracion] ([IDEscalaValoracion])
ON DELETE CASCADE
GO
ALTER TABLE [Evaluacion360].[tblDetalleEscalaValoracion] CHECK CONSTRAINT [Fk_Evaluacion360TblDetalleEscalaValoracion_IDEscalaValoracion]
GO
