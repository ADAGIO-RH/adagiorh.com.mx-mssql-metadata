USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Asistencia].[tblUsuariosZKFaces](
	[IDUsuariosZKFace] [int] IDENTITY(1,1) NOT NULL,
	[IDEmpleado] [int] NOT NULL,
	[EnrollNumber] [varchar](25) COLLATE SQL_Latin1_General_CP1_CI_AI NOT NULL,
	[FaceIndex] [int] NOT NULL,
	[Size] [int] NOT NULL,
	[Valid] [bit] NOT NULL,
	[FaceTemplate] [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NOT NULL,
	[Version] [varchar](25) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
 CONSTRAINT [PK_AsistenciaTblUsuariosZKFaces_IDUsuariosZKFace] PRIMARY KEY CLUSTERED 
(
	[IDUsuariosZKFace] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [Asistencia].[tblUsuariosZKFaces]  WITH CHECK ADD  CONSTRAINT [FK_RHtblEmpleados_AsistenciaTblUsuariosZKFaces_IDEmpleado] FOREIGN KEY([IDEmpleado])
REFERENCES [RH].[tblEmpleados] ([IDEmpleado])
GO
ALTER TABLE [Asistencia].[tblUsuariosZKFaces] CHECK CONSTRAINT [FK_RHtblEmpleados_AsistenciaTblUsuariosZKFaces_IDEmpleado]
GO
