USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Norma35].[tblRegistroNotasColaborador](
	[IDRegistroNotasColaborador] [int] IDENTITY(1,1) NOT NULL,
	[IDEmpleado] [int] NOT NULL,
	[Titulo] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[Notas] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[FechaRegistro] [datetime] NULL,
	[IDUsuarioRegistro] [int] NULL,
 CONSTRAINT [Pk_Norma35tblRegistroNotasColaborador_IDRegistroNotasColaborador] PRIMARY KEY CLUSTERED 
(
	[IDRegistroNotasColaborador] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [Norma35].[tblRegistroNotasColaborador]  WITH CHECK ADD  CONSTRAINT [FK_RHtblEmpleados_Norma35tblRegistroNotasColaborador_IDEmpleado] FOREIGN KEY([IDEmpleado])
REFERENCES [RH].[tblEmpleados] ([IDEmpleado])
GO
ALTER TABLE [Norma35].[tblRegistroNotasColaborador] CHECK CONSTRAINT [FK_RHtblEmpleados_Norma35tblRegistroNotasColaborador_IDEmpleado]
GO
